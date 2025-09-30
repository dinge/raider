# frozen_string_literal: true

module Raider
  module Tasks
    class Base
      attr_reader :app, :llm, :provider
      attr_reader :agent
      attr_reader :task_runner
      attr_accessor :task_context
      attr_reader :input, :inputs

      alias context task_context

      delegate :set_system_prompt, :chat, :ruby_llm_base_client, :chat_message_with_images, :chat_with_responses, to: :@task_runner
      delegate :output, :outputs, to: :@task_context

      def ident = self.class.name.split('::').last.underscore.to_sym

      def initialize(task_runner:, app:, llm:, provider:, agent: nil)
        @task_runner = task_runner
        @app = app
        @llm = llm
        @provider = provider
        @agent = agent

        @task_context = Utils::TaskContext.new(default_context)
      end

      def default_context
        {
          provider: @provider.provider_ident,
          llm: @llm.llm_ident,
          input: nil, # will be overwritten with final prompt from task, currently not processed
          inputs: {}, # currently not processed
          output: nil,
          outputs: {}, # currently not processed
          tool_calls: [],
          llm_usages: [],
          as: nil
        }
      end



      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end


      def with_tools? = tools.present?

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

      def tools
        {}
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
