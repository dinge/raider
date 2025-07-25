# frozen_string_literal: true

module Raider
  module Agents
    class Base
      attr_reader :app, :llm, :provider
      attr_reader :agent_runner, :input, :agent_context

      alias context agent_context

      def initialize(app:, llm:, provider:, agent_runner:, input: nil)
        @app = app
        @llm = llm
        @provider = provider
        @agent_runner = agent_runner
        @input = input
        @agent_context = Raider::Utils::AgentContext.new(provider: @provider.provider_ident,
                                                         llm: @llm.llm_ident,
                                                         input:,
                                                         tasks: [],
                                                         data: {})
      end

      def process(&proc)
        proc.call(self)
        @agent_runner
      end

      def run_task(task_ident, **args)
        task = app.create_task(task_ident, llm: nil, provider: nil, agent: self)

        WebMock.enable!
        VCR.use_cassette(build_vcr_key(task_ident), record: :new_episodes) do
          task.process(**args)
        end
        WebMock.disable!

        agent_context.tasks << { task_ident.to_sym => task.context.to_hash }
        task.task_runner
      end

      def build_vcr_key(task_ident)
        [
          app.app_ident,
          app.context.vcr_key.version_key,
          app.context.vcr_key.source_ident,
          [task_ident, @llm.llm_ident, app.context.vcr_key.reprocess_ident].join('--')
         ].join('/')
      end
    end
  end
end
