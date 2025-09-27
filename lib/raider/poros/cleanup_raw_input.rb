# frozen_string_literal: true

module Raider
  module Poros
    class CleanupRawInput
      ALLOWED_LETTERS_AND_NUMBERS = '\p{L}\p{M}\p{Nd}\p{Nl}'
      ALLOWED_CONNECTORS = '\p{Pc}'
      ALLOWED_WHITESPACE = '\s\n\r'
      ALLOWED_SYMBOLS = "@\\$<>\(\)\+\-\/,\.\!\*&;:%^'\"€£¥–—_\\[\\]\{\}"
      ALLOWED_CHARACTERS_REGEX = /[^#{ALLOWED_LETTERS_AND_NUMBERS}#{ALLOWED_CONNECTORS}#{ALLOWED_WHITESPACE}#{ALLOWED_SYMBOLS}]/u.freeze

      SANITIZER = Rails::HTML5::SafeListSanitizer.new

      def initialize(input)
        @input = input
      end

      def process
        sanitize_text(@input)
          .then { filter_allowed_characters(it) }
          .then { clean_whitespace(it) }
      end

      private

      def sanitize_text(input)
        SANITIZER.sanitize(input, tags: []) || ''
      end

      def filter_allowed_characters(input)
        input.gsub(ALLOWED_CHARACTERS_REGEX, '') || ''
      end

      def clean_whitespace(input)
        input.gsub(/\n{2,}/, "\n")
             .squish!
      end
    end
  end
end
