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
        #@context = context
      end

      def process(prompt)
        raise NotImplementedError
      end

      def chat(prompt) = @task_runner.chat_message(prompt)

      def chat_message_with_images(prompt, images)
        images = images.map { base64_encode(_1) }
        @task_runner.chat_message_with_images(prompt:, images:)
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
          main_date: "Main document date in YYYY-MM-DD format",
          category: "Document category"
        }
      end

      private

      def base64_encode(image) = Base64.strict_encode64(File.binread(image))
    end
  end
end
