# frozen_string_literal: true

module Raider
  module Tasks
    class ValueCorrector < Base
      def process(input_value, valid_values)
        set_system_prompt(system_prompt)
        chat(prompt(input_value, valid_values))
      end

      def system_prompt
        <<~SYSTEM
          Your are a powerful input_value correction tool.
          You work 100% accurate and make no mistakes.
          You get an input_value.
          You use the input_value to find the best_matching_value from a list of valid_values.
          You use if needed advance algorythms like Jaro-Winkler Distance and N-gram.
          Then return the best_matching_value as valid JSON format.
        SYSTEM
      end

      def prompt(input_value, valid_values)
        <<~TEXT
          input_value: #{input_value}
          valid_values: #{valid_values.join(', ')}

          return the best_matching_value

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          response: 'best_matching_value'
        }
      end
    end
  end
end
