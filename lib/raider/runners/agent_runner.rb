# frozen_string_literal: true

module Raider
  module Runners
    class AgentRunner
      attr_reader :app, :llm, :provider
      attr_reader :current_agent, :current_outputs

      def initialize(app:, llm:, provider:)
        @app = app
        @llm = llm
        @provider = provider
        @current_agent_class = Raider::Agents::Base
        @current_agent_ident = nil

        @current_output_items = []
        @current_outputs_items = []
        @current_errors = []
      end

      def process(agent_ident, input:, &proc)
        @current_agent = init_agent(agent_ident:, input:)
        add_agent_to_app!
        @current_agent.process(&proc) # process tasks in agent block

        add_to_output!(finalize: true)
        @current_agent
      end

      def tasks = Utils::CallerProxy.new(self, to: :run_task)
      def ptasks = Utils::CallerProxy.new(self, to: :run_ptask)
      def response_from = Utils::CallerProxy.new(self, to: :run_response_from)

      def run_task(task_ident, **args)
        task_options = args.extract!(:llm, :provider)
        # basic task run without context management
        task = @app.create_task(task_ident, llm: task_options[:llm], provider: task_options[:provider], agent: self)
        task.context.as = args.extract!(:as).dig(:as)
        all_inputs = args.slice(:input, :inputs)
        task.context.merge!(all_inputs)
        add_to_output!(output: task.alias_or_ident) #.to_s.titleize
        # add_to_output!(output: task.alias_or_ident, outputs: all_inputs)
        call_back_on_task_create!(task)

        process_task_and_response!(task, task_ident, **args)

        call_back_on_task_response!(task)
        task.task_runner
      end

      def process_task_and_response!(task, task_ident, **args)
        current_retries = 0
        begin
          process_task!(task, task_ident, **args)
          process_task_response!(task, task_ident)
        rescue => error
          error_message = error.to_s.presence || error.class.name
          add_to_output!(error: { task_ident => error_message })
          if @app.context.retries_on_exception.presence.to_i > 0 && current_retries <= app.context.retries_on_exception
            current_retries += 1
            Raider.log(agent: @agent_ident, task: task_ident, retry_on_exception: current_retries, error: error_message)
            sleep(1)
            retry
          else
            if @app.context.reraise_exception.present?
              @app.persisted_app&.destroy if @app.context.destroy_app_persistence_on_exception.present?
              raise error.class, error.message
            end
            process_task_response!(task, task_ident, error:)
          end
        end
      end

      def run_response_from(response_ident, &proc)
        run_task(:process_response_from, as: response_ident, inputs: { response_from: proc })
      end

      def ask(input = nil, **args)
        args.reverse_merge!(input:)
        run_task(:ask, **args).context.output.to_h.dig(:response)
      end

      def add_to_output!(output: nil, outputs: {}, finalize: false, llm_usages: [], tool_calls: [], error: nil)
        return unless @app.context.with_auto_context.present?

        # @current_output_items << output.try(:to_markdown) || output if output.present?
        @current_output_items << output if output.present?
        @current_outputs_items << outputs if outputs.compact_blank.presence
        @current_errors << error if error.present?

        # @app.context.output = finalize ? @current_output_items.last : @current_output_items.join(' + ')
        # @app.context.outputs = finalize ? @current_outputs_items.last : @current_outputs_items
        @app.context.llm_usages << llm_usages if llm_usages.present?
        @app.context.tool_calls.concat(tool_calls) if tool_calls.present?

        @app.context.output = @current_output_items.last
        @app.context.outputs = @current_outputs_items.reduce({}, :merge)
                                 .merge({ llm_usages: @app.context.llm_usages,
                                          tool_calls: @app.context.tool_calls,
                                          errors: @current_errors.presence }.compact_blank)
        update_app_persistence!(finalize:)
      end

      protected

      def init_agent(agent_ident:, input:)
        @current_agent_ident = agent_ident
        agent_class = @current_agent_ident.to_s.camelize
        if Raider::Agents.const_defined?(agent_class)
          @current_agent_class = Raider::Agents.const_get(agent_class)
        end
        @current_agent_class.new(app:, llm:, provider:, agent_runner: self, input:, agent_ident: @current_agent_ident)
      end

      def add_agent_to_app!
        @app.context.add_agent!(@current_agent_ident, @current_agent)
        @app.persisted_app ||= create_app_persistence!
      end

      # task processing
      #################

      def process_task!(task, task_ident, **args)
        return process_task_with_vcr(task, **args) if @app.context.vcr_key.present? || @app.context.with_vcr

        process_task_without_vcr(task, **args)
      end

      def process_task_response!(task, task_ident, error: nil)
        if error
          task_response_output = error.message
          task_response_outputs =
            { error: {
                task_ident:,
                exception: error,
                message: error.message
            } }
        else
          @current_agent.agent_context.add_task!(task)
          @app.context.add_agent_task!(@current_agent_ident, task)
          task_response_output = task.output&.response.presence || task.output.to_h
          task_response_outputs = task_response_output
        end

         add_to_output!(output: task_response_output,
                       outputs: { task.alias_or_ident => task_response_outputs },
                       llm_usages: { task.alias_or_ident => task.context.llm_usages },
                       tool_calls: task.task_runner.tool_calls)
      end

      # callbacks
      ###########

      def call_back_on_task_create!(task)
        return unless @app.context.on_task_create.present?

        @app.send(@app.context.on_task_create, task)
      end

      def call_back_on_task_response!(task)
        return unless @app.context.on_task_response.present?

        @app.send(@app.context.on_task_response, task)
      end

      # persistence
      #############

      def create_app_persistence!
        return unless @app.context.with_app_persistence.present?

        reference = case @app.upstream
          when Raider::Source
            { source: @app.upstream, upstream: @app.upstream }
          when @persistence_class
            { parent_app: @app.upstream, upstream: @app.upstream }
          else
            { source: nil, upstream: @app.upstream }
          end

        title = [@app.app_class_name, @app.upstream.try(:id), DateTime.now.to_fs(:long), @app.context.llm].join(' / ')

        @app.persistence_class.create!(
          { title:,
            llm: @app.context.llm,
            provider: @app.context.provider,
            processor_class: @app.context.processor_class,
            raider_app_class: @app.app_class_name,
            input: @app.context.input,
            inputs: @app.context.inputs,
            context: @app.context.to_hash,
            started_at: DateTime.now.utc }.merge(reference)
        )
      end

      def update_app_persistence!(finalize: false)
        return unless @app.context.with_app_persistence.present?

        @app.persisted_app.reload.update!(
          output: @app.context.output,
          outputs: @app.context.outputs,
          context: @app.context.to_hash,
          ended_at: DateTime.now.utc,
          finalized_at: finalize ? DateTime.now.utc : nil
        )
      end

      # VCR handling
      ################

      def process_task_with_vcr(task, **args)
        WebMock.enable!
        vcr_path = build_vcr_path(task)
        Raider.log(agent: @agent_ident, vcr_path:)
        VCR.use_cassette(vcr_path, record: @app.context.vcr.mode) { task.process(**args) }
        WebMock.disable!
      end

      def process_task_without_vcr(task, **args)
        Raider.log(agent: @agent_ident, run_without_vcr_key: true)
        task.process(**args)
      end

      def build_vcr_path(task)
        current_number_of_tasks = @current_agent.agent_context.fetch_number_of_tasks_by_ident(task.alias_or_ident)
        [ @app.app_ident,
          @app.context.vcr_key.version_key,
          @app.context.vcr_key.source_ident,
          [task.alias_or_ident, current_number_of_tasks, @llm.llm_ident, @app.context.vcr_key.reprocess_ident].join('--')
        ].join('/')
      end
    end
  end
end
