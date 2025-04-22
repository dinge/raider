# frozen_string_literal: true

module Raider
  module Tasks
    class NameCorrector < Base
      def process(receiver_name, valid_receivers)
        set_system_prompt(system_prompt)
        chat(prompt(receiver_name, valid_receivers))
      end

      def system_prompt
        <<~SYSTEM
          Your are a powerful name correction tool.
          You accept a given_name
          Your job is to find the one best_fitting_name to given_name from a list of available_names.

          Always respond in valid JSON format.
        SYSTEM
      end

      def prompt(receiver_name, valid_receivers)
        <<~TEXT
          given_name: #{receiver_name}
          available_names: #{valid_receivers.join(', ')}

          return the best_fitting_name

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          response: 'best_fitting_name'
        }
      end
    end
  end
end
