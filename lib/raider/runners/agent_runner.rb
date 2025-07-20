# frozen_string_literal: true

module Raider
  module Runners
    class AgentRunner
      attr_reader :app, :llm, :provider
      attr_reader :current_agent, :current_context

      alias context current_context

      def initialize(app:, llm:, provider:)
        @app = app
        @llm = llm
        @provider = provider
      end

      def process(agent_ident, input:)
        # @current_agent = Raider::Agents.const_get(task.to_s.camelize).new(app:, llm:, provider:, agent_runner: self)
        @current_agent = Raider::Agents::Base.new(app:, llm:, provider:, agent_runner: self, input:)
        @current_context = @current_agent.agent_context
        @current_agent
      end
    end
  end
end
