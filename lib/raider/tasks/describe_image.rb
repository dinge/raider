# frozen_string_literal: true

module Raider
  module Tasks
    class DescribeImage < Base
      def process(image)
        set_system_prompt(system_prompt)
        chat_message_with_images(prompt, [image])
      end

      def prompt
        <<~TEXT
          describe all what you see, think deeply
          #{json_instruct}
        TEXT
      end

      def system_prompt
        <<~SYSTEM
          You are a specialized document analysis expert with the following capabilities:
          - Deep understanding of business documents and their structure
          - Expertise in German and English business correspondence
          - Precise extraction of dates, names, and document types
          - Accurate recognition of company letterheads and logos
          - Reliable handling of different document layouts

          Focus areas:
          1. Accurate text extraction from images
          2. Proper date format conversion
          3. Reliable sender/receiver identification
          4. Correct document type classification

          Always respond in valid JSON format.
        SYSTEM
      end
    end
  end
end
