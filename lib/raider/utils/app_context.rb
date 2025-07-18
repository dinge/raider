# frozen_string_literal: true

module Raider
  module Utils
    class AppContext < BaseContext
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
