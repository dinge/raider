# frozen_string_literal: true

module Raider
  module Tasks
    class Base
      attr_reader :app, :llm, :provider
      attr_reader :agent
      attr_reader :task_runner
      attr_accessor :task_context

      alias context task_context

      def initialize(task_runner:, app:, llm:, provider:, agent: nil)
        @app = app
        @llm = llm
        @provider = provider
        @agent = agent

        @task_runner = task_runner
        @task_context = Utils::TaskContext.new(provider: @provider.provider_ident, llm: @llm.llm_ident)
      end

      delegate :set_system_prompt, :chat, :ruby_llm_base_client, :chat_message_with_images, to: :@task_runner

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
          ## Output
          Return **only** the JSON object below—nothing else. Keep key order fixed.
          ```json
            #{JSON.pretty_generate(example_response_struct)}
          ```
        TEXT
      end

      def llm_options
        { default_options: }
      end

      def default_options
        {}
      end

      def example_response_struct
        {
          response: 'your description after deep analysis'
        }
      end
    end
  end
end
