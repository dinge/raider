# frozen_string_literal: true

module Raider
  module Apps
    class Base
      class_attribute :provider, default: :open_ai
      class_attribute :llm

      attr_accessor :app_context
      attr_accessor :llm_class

      alias context app_context

      def app = self

      def initialize(app_context = {})
        @app_context = Utils::AppContext.new(
          app_context.reverse_merge(provider:, agents: [], tasks: [], data: {}, outputs: {})
        )
      end

      def app_ident = self.class.name.split('::').last.underscore

      def pdf_files
        Dir.glob(File.join(@app_context.input_path, '**/*.pdf')).shuffle
      end

      def create_task(task_ident, llm: nil, provider: nil, agent: nil)
        init_llm_setup!(provider, llm)
        Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider, agent:).process(task_ident)
      end

      def create_agent(agent_ident, llm: nil, provider: nil, input: nil)
        init_llm_setup!(provider, llm)
        Runners::AgentRunner.new(app: self, llm: @llm, provider: @provider).process(agent_ident, input:)
      end

      def run_agent(agent_ident, llm: nil, provider: nil, input: nil, &proc)
        agent = create_agent(agent_ident, llm:, provider:, input:)
        agent_runner = agent.process(&proc)
        app.context.agents << { agent_ident.to_sym => agent_runner.current_context.to_hash }
        agent_runner
      end

      def init_llm_setup!(provider, llm)
        init_provider(provider)
        init_llm_class(llm)
        init_llm
      end

      def init_provider(provider)
        @provider = "Raider::Providers::#{provider || @app_context.provider.to_s.classify}".constantize.new
      end

      def init_llm
        @llm = @llm_class.new(app: self, provider: @provider)
      end

      def init_llm_class(llm)
        llm_class_name = (llm || app_context.llm || @provider.default_llm_ident).to_s.classify
        @llm_class = if Raider::Llms.const_defined?(llm_class_name)
                       Raider::Llms.const_get(llm_class_name)
                     else
                       Raider::Llms.const_get(llm_class_name)
                       # Raider::Llms::Dummy
                     end
      end

      def dump(entry) = puts JSON.pretty_generate(entry)

      # def create_task(task, llm: nil, provider: nil)
      #   run_with_setup(llm:, provider:) do
      #     Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider).process(task)
      #   end
      # end

      # def run_with_setup(llm:, provider:)
      #   p = "Raider::Providers::#{provider || @app_context[:provider].classify}".constantize.new
      #   llm_class_name = (llm || @app_context[:llm] || p.default_llm_ident).to_s.classify
      #   l= "Raider::Llms::#{llm_class_name}".constantize.new(app: self, provider: p)
      #   Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider).process(task)
      # end
    end
  end
end
