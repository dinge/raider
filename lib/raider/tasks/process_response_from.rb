# frozen_string_literal: true

module Raider
  module Tasks
    class ProcessResponseFrom < Base
      def process(input: nil, inputs: {})
        task_context.output = inputs.dig(:response_from).call
      end
    end
  end
end
