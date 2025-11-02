# frozen_string_literal: true

module Raider
  module Tasks
    class ProcessResponseFrom < Base
      def process(input: nil, inputs: {})
        response = inputs.dig(:response_from).call
        task_context.output = response.is_a?(Array) ? { response: } : response
      end
    end
  end
end
