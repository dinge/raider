# frozen_string_literal: true

module Raider
  module Runners
    class AgentRunner
      attr_reader :app, :llm, :provider
      attr_reader :current_agent

      def initialize(app:, llm:, provider:)
        @app = app
        @llm = llm
        @provider = provider
        @current_agent_class = Raider::Agents::Base
        @current_agent_ident = nil

        @temp_output_messages = []
      end

      def process(agent_ident, input:, &proc)
        @current_agent = init_agent(agent_ident:, input:)
        add_agent_to_app!
        @current_agent.process(&proc) # process tasks in agent block

        add_to_output(last: true)
        @current_agent
      end

      def tasks = Utils::CallerProxy.new(self, to: :run_task)

      def run_task(task_ident, **args)
        task_options = args.extract!(:llm, :provider)
        task = @app.create_task(task_ident, llm: task_options[:llm], provider: task_options[:provider], agent: self)
        task.context.as = args.extract!(:as).dig(:as)
        add_to_output(output: task.ident)
        call_back_on_task_create!(task)
        process_task!(task, task_ident, **args)
        process_task_response!(task, task_ident)
        task.task_runner
      end

      protected

      def add_to_output(output: nil, last: false)
        return unless @app.context.with_auto_context.present?

        @temp_output_messages << output if output
        @app.context.output = last ? @temp_output_messages.last : @temp_output_messages.join("\n")
        update_app_persistence!
      end

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

      def process_task!(task, task_ident, **args)
        @app.context.vcr_key ? process_task_with_vcr(task, task_ident, **args) : process_task_without_vcr(task, **args)
      end

      def process_task_response!(task, task_ident)
        @current_agent.agent_context.add_task!(task_ident, task)
        @app.context.add_agent_task!(@current_agent_ident, task_ident, task)

         if @app.context.with_auto_context.present?
           @app.context.outputs[task.context.as || task_ident] = task.output.response
         end

        add_to_output(output: task.output.response)
        call_back_on_task_reponse!
      end



      def call_back_on_task_create!(task)
        return unless @app.context.on_task_create.present?

        @app.send(@app.context.on_task_create, task)
      end

      def call_back_on_task_reponse!
        return unless @app.context.on_task_reponse.present?

        @app.send(@app.context.on_task_reponse, task)
      end

      def update_app_persistence!
        return unless @app.context.with_app_persistence.present?

        @app.persisted_app.update!(
          output: @app.context.output,
          outputs: @app.context.outputs,
          context: @app.context.to_hash
        )
#        @app.persisted_app.update!(ended_at: DateTime.now.utc) unless @app.persisted_app.ended_at.present?
      end

      def process_task_with_vcr(task, task_ident, **args)
        WebMock.enable!
        vcr_path = build_vcr_path(task_ident)
        Raider.log(agent: @agent_ident, vcr_path: vcr_path)
        VCR.use_cassette(vcr_path, record: :new_episodes) { task.process(**args) }
        WebMock.disable!
      end

      def process_task_without_vcr(task, **args)
        Raider.log(agent: @agent_ident, run_without_vcr_key: true)
        task.process(**args)
      end

      def build_vcr_path(task_ident)
        current_number_of_tasks = @current_agent.agent_context.fetch_number_of_tasks_by_ident(task_ident)
        [
          @app.app_ident,
          @app.context.vcr_key.version_key,
          @app.context.vcr_key.source_ident,
          [task_ident, current_number_of_tasks, @llm.llm_ident, @app.context.vcr_key.reprocess_ident].join('--')
         ].join('/')
      end

      def create_app_persistence!
        return unless @app.context.with_app_persistence.present?
        # title = "#{self.class.name.split('::').last} | #{upstream.id} - #{DateTime.now.to_fs(:long)} - #{self.class::LLM}"

        reference = case @upstream
          when Raider::Source
            { source: upstream, upstream: }
          when Raider::App
            { parent_app: upstream, upstream: }
          else
            { source: Raider::Source.first, upstream: Raider::Source.first }
          end

        title = [@app.app_class_name, DateTime.now.to_fs(:long), @app.context.llm].join(' / ')
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
    end
  end
end
