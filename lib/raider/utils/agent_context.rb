# frozen_string_literal: true

module Raider
  module Utils
    class AgentContext < BaseContext
      def find_task(task_ident)
        task_context = tasks.find { it.keys.include?(task_ident) }.values.first
        TaskContext.new(task_context)
      end

      def task_response_from(task_ident)
        find_task(task_ident).response
      end
    end
  end
end
