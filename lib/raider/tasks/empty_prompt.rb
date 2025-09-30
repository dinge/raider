# frozen_string_literal: true

module Raider
  module Tasks
    class EmptyPrompt < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end

      def system_prompt
        <<~SYSTEM
          you are a helpful agent

          #{json_instruct}
        SYSTEM
      end

      def prompt
        { input:, inputs: }.compact_blank
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

      def example_response_struct
        {
          response: 'your reponse'
        }
      end
    end
  end
end
