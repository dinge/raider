# frozen_string_literal: true

module Raider
  module Poros
    class CleanupRawInput
      def initialize(input)
        @input = input
      end

      def process
        @input
      end
    end
  end
end
