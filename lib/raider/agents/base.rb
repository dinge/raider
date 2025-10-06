# frozen_string_literal: true

module Raider
  module Agents
    class Base
      attr_reader :app, :llm, :provider
      attr_reader :agent_runner, :input, :agent_context

      alias context agent_context

      delegate :run_task, :tasks, :ask, :response_from, to: :@agent_runner

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
          data: {} # neeeded?
        }
      end

      def process(&proc) = proc.call(self)
    end
  end
end
