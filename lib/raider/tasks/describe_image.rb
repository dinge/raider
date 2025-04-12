module Raider
  module Tasks
    class DescribeImage < Base

      def process(image)
        chat_message_with_image(prompt, image)
      end

      def prompt
        <<~TEXT
        describe all what you see, think deeply

        Return ONLY a JSON object with this structure:
        {
          "description": 'your description after deep analysis',
          "main_date": "Main document date in YYYY-MM-DD format",
          "category": "Document category"
        }
        TEXT
      end

      # def prompt
      #   <<~TEXT
      #   Act as a professional experienced document analysis expert.
      #   You can read and understand German text.
      #   You have to analyze given business document, it is likely in German language - but can also be in English.
      #   Read the document and extract following information:

      #   1. The sender (from letterhead, company logo, or sender details, or sender address block)
      #   2. The recipient (from address block or recipient field)
      #   3. The primary document date (the current year is #{Time.now.year})
      #   4. The document type in German

      #   Important:
      #   - Use YYYY-MM-DD format for dates
      #   - For Category use the most fitting german type like (rechnung, mahnung, anschreiben, angebot, prüfung, verschiedenes)
      #   - if no category fits exactly, find out what type the document is
      #   - Use "unknown" for unclear values, don't hallucinate
      #   - No additional text or explanations
      #   - Focus on accuracy and maintain the exact JSON structure

      #   Return ONLY a JSON object with this structure:
      #   {
      #     "sender_name": "Company or person who sent the document",
      #     "receiver_name": "Company or person receiving the document",
      #     "main_date": "Main document date in YYYY-MM-DD format",
      #     "category": "Document category in German"
      #   }
      #   TEXT
      # end
    end
  end
end
