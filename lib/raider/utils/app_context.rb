# frozen_string_literal: true

module Raider
  module Utils
    class AppContext < BaseContext

      def add_agent!(agent_ident, agent)
        return if fetch_agent(agent_ident)

        agents << { agent_ident.to_sym => agent.context.to_hash }
        fetch_agent(agent_ident)
      end

      def add_agent_task!(agent_ident, task)
        return if agent_task_exists?(agent_ident, task)

        fetch_agent(agent_ident).tap do
          it.tasks << { task.alias_or_ident => task.context.to_hash }
        end
      end

      def fetch_agent(agent_ident)
        agent_context = agents.find { it.keys.include?(agent_ident.to_sym) }&.values&.first
        agent_context.present? ? AgentContext.new(agent_context) : nil
      end

      def fetch_agent_task(agent_ident, task_ident)
        fetch_agent(agent_ident.to_sym)&.fetch_task(task_ident)
      end

      def agent_task_exists?(agent_ident, task)
        fetch_agent(agent_ident.to_sym)&.fetch_task(task.alias_or_ident).present?
      end

      def dump_tasks
        agents.flat_map do |a|
          a.map do |agent_title, agent_vals|
            { agent_title => agent_vals[:tasks]&.map(&:keys)&.flatten }
          end
        end
      end

      def dump_full_tasks
        agents.flat_map do |a|
          a.map do |agent_title, agent_vals|
            {
              agent_title => agent_vals[:tasks].map do |task_hash|
                { task_hash.keys.first => task_hash.values.first.slice(:input, :output) }
              end
            }
          end
        end
      end
    end
  end
end
