# frozen_string_literal: true

module Raider
  module Runners
    class AgentRunner
      attr_reader :response, :response_message, :app, :llm, :provider

      def initialize(app:, llm:, provider:)
        @app = app
        @llm = llm
        @provider = provider
        # @context = context
      end

      def process(task)
        Raider::Agents.const_get(task.to_s.classify).new(agent_runner: self, app:, llm:, provider:)
      end
    end
  end
end
