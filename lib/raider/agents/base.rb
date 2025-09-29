# frozen_string_literal: true

module Raider
  module Agents
    class Base
      attr_reader :app, :llm, :provider
      attr_reader :agent_runner, :input, :agent_context

      alias context agent_context

      def initialize(agent_ident:, app:, llm:, provider:, agent_runner:, input:)
        @agent_ident = agent_ident
        @app = app
        @llm = llm
        @provider = provider
        @agent_runner = agent_runner
        @input = input
        @agent_context = Raider::Utils::AgentContext.new(default_context)
      end

      def default_context
        {
          provider: @provider.provider_ident,
          llm: @llm.llm_ident,
          input: @input,
          tasks: [],
          data: {}
        }
      end

      def process(&proc)
        proc.call(self)
        @agent_runner
      end

      def run_task(task_ident, **args)
        task_options = args.extract!(:llm, :provider)

        # run basic task from app
        task = app.create_task(task_ident, llm: task_options[:llm], provider: task_options[:provider], agent: self)

        app.context.vcr_key ? run_task_with_vcr(task, task_ident, **args) : run_task_without_vcr(task, **args)

        agent_context.tasks << { task_ident.to_sym => task.context.to_hash }
        task.task_runner
      end


      protected

      # TODO: move to AgentRunner, also below
      def run_task_with_vcr(task, task_ident, **args)
        WebMock.enable!
        final_key = build_vcr_key(task_ident)
        Raider.log(agent: @agent_ident, final_vcr_key: final_key)
        VCR.use_cassette(final_key, record: :new_episodes) do
          task.process(**args)
        end
        WebMock.disable!
      end

      def run_task_without_vcr(task, **args)
        Raider.log(agent: @agent_ident, run_without_vcr_key: true)
        task.process(**args)
      end

      def build_vcr_key(task_ident)
        current_number_of_tasks = agent_context.select_task_names(task_ident).count
        [
          app.app_ident,
          app.context.vcr_key.version_key,
          app.context.vcr_key.source_ident,
          [task_ident, current_number_of_tasks, @llm.llm_ident, app.context.vcr_key.reprocess_ident].join('--')
         ].join('/')
      end
    end
  end
end
