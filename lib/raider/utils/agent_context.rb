# frozen_string_literal: true

module Raider
  module Utils
    class AgentContext < BaseContext
      def add_task!(task_ident, task)
        { task_ident.to_sym => task.context.to_hash }.tap do
          tasks << it
        end
      end

      def fetch_task(task_ident)
        task_context = tasks.find { it.keys.include?(task_ident.to_sym) }&.values&.first
        task_context.present? ? TaskContext.new(task_context) : nil
      end

      def fetch_tasks_by_ident(task_ident)
        tasks.select { it.keys.include?(task_ident.to_sym) }.map(&:values)
      end

      def fetch_number_of_tasks_by_ident(task_ident)
        fetch_tasks_by_ident(task_ident).count
      end

      def task_response_from(task_ident)
        fetch_task(task_ident).response
      end
    end
  end
end
