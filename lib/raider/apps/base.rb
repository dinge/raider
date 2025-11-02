# frozen_string_literal: true

module Raider
  module Apps
    class Base
      class_attribute :provider, default: :open_ai
      class_attribute :llm

      attr_accessor :llm_class
      attr_accessor :app_context, :upstream
      attr_accessor :persisted_app, :persistence_class

      alias context app_context

      delegate :input, :inputs, :output, :outputs, to: :app_context
      delegate :dump_tasks, :dump_full_tasks, to: :app_context

      def app = self
      def app_class_name = self.class.name.split('::').last
      def app_ident = app_class_name.underscore

      def initialize(input_context = {})
        Raider.log(start_app: app_ident, input_context: input_context.to_hash)
        @upstream = input_context.extract!(:upstream).dig(:upstream)
        @persistence_class = Raider.const_defined?('App') ? Raider::App : nil
        handle_context!(input_context)
        handle_logger!
        handle_vcr!
        Raider.log(start_app: app_ident, context: context.to_hash)
      end

      def default_context
        { provider:,
          llm: nil,

          input: nil,
          inputs: nil,
          output: nil,
          outputs: {},
          upstream_global_id: nil,

          agents: [],

          processor_class: nil,
          raider_app_class: app_class_name,
          # data: {},

          debug: true,

          cleanup_inputs: false, # TODO: implement

          reprocess: false, # TODO: use

          with_vcr: false,
          vcr: {
            mode: :new_episodes
          },
          vcr_key: {
            version_key: 0,
            source_ident: nil,
            reprocess_ident: nil
          },

          reraise_exception: true,
          retries_on_exception: 0,
          destroy_app_persistence_on_exception: false,
          with_app_persistence: false,
          with_auto_context: false,
          on_task_create: false,
          on_tool_call: false,
          on_tool_response: false,
          on_tool_process: false,
          on_tool_process_response: false,
          on_task_response: false,

          tool_calls: [],
          llm_usages: []
        }
      end

      # basic task run without context management
      def create_task(task_ident, llm: nil, provider: nil, agent: nil)
        init_llm_setup!(provider, llm)
        Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider, agent:).process(task_ident)
      end

      def agents = Utils::CallerProxy.new(self, to: :run_agent)

      def run_agent(agent_ident, llm: nil, provider: nil, input: nil, &proc)
        init_llm_setup!(provider, llm)
        Raider.log(start_agent: agent_ident, provider:, llm:)
        agent_runner = Runners::AgentRunner.new(app: self, llm: @llm, provider: @provider).process(agent_ident, input:, &proc)
        Raider.log(stop_agent: agent_ident)
        agent_runner
      end

      def chat(input)
        create_task(:empty_prompt).process(input:) unless @app_context.with_app_persistence.present?

        run_agent(:chat, input:) do |ag|
          ag.run_task(:empty_prompt, input:)
        end
      end

      ## TODO: move to AppRunner
      def handle_context!(input_context)
        context_hash = input_context.reverse_merge(default_context)
                                    # .reverse_merge(processor_class: @upstream.try(&:processor_class).presence)
                                    .merge!(upstream_global_id: @upstream&.to_global_id.to_s.presence)
        @app_context = Utils::AppContext.new(context_hash)

        if @app_context.with_app_persistence.present? && @persistence_class.blank?
          raise StandardError, 'no app persistance class defined'
        end
      end

      def handle_logger!
        Raider.logger.level = Logger::DEBUG if @app_context.debug ||= ENV['DEBUG'] == 'true'
      end

      def handle_vcr!
        @app_context.vcr_key.source_ident ||=
          @upstream.try(:source_ident) ||
            @upstream.try(:id) ||
            Digest::SHA2.hexdigest(input.to_s + inputs.to_s)
      end

      def init_llm_setup!(provider, llm)
        init_provider(provider)
        init_llm_class(llm)
        init_llm
      end

      def init_provider(provider)
        @provider = "Raider::Providers::#{provider || @app_context.provider.to_s.camelize}".constantize.new
      end

      def init_llm
        @llm = @llm_class.new(app: self, provider: @provider)
      end

      def init_llm_class(llm)
        llm_class_name = (llm || @app_context.llm || @provider.default_llm_ident).to_s.camelize
        @llm_class = Raider::Llms.const_defined?(llm_class_name) ?
                       Raider::Llms.const_get(llm_class_name) :
                       Raider::Llms.const_get(llm_class_name)
      end


      def pdf_files
        Dir.glob(File.join(@app_context.input_path, '**/*.pdf')).shuffle
      end

      def dump(entry) = puts JSON.pretty_generate(entry)
    end
  end
end
