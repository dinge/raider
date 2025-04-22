# frozen_string_literal: true

module Raider
  module Llms
    class Llama4MaverickSmall < Base
      def default_options
        {
          temperature: 0.2
        }
      end
    end
  end
end
