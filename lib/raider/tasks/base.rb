# frozen_string_literal: true

module Raider
  module Tasks
    class Base
      attr_accessor :context
      attr_reader :task_runner

      def initialize(task_runner:, app:, llm:, provider:)
        @task_runner = task_runner
        @app = app
        @llm = llm
        @provider = provider
        # @context = context
      end

      delegate :set_system_prompt, :chat, :chat_message_with_images, to: :@task_runner

      def process(prompt)
        raise NotImplementedError
      end

      def prompt
        <<~TEXT
          describe all what you see, think deeply
          #{json_instruct}
        TEXT
      end

      def json_instruct
        <<~TEXT
          Return ONLY a JSON object with this structure:
          #{example_response_struct}
        TEXT
      end

      def example_response_struct
        {
          description: 'your description after deep analysis',
          main_date: 'Main document date in YYYY-MM-DD format',
          category: 'Document category'
        }
      end
    end
  end
end
