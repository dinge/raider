require_relative 'base_prompt'

module Prompts
  class Llama3Prompt < Base
    def analyze_document
      <<~TEXT
        Act as a document analysis expert, analyze this image and extract:

        1. The sender (from letterhead, company logo, or sender details, or sender address block)
        2. The recipient (from address block or recipient field)
        3. The primary document date (the current year is #{Time.now.year})
        4. The document type in German

        Important:
        - Use YYYY-MM-DD format for dates
        - For Category use the most fitting german type like (rechnung, mahnung, anschreiben, angebot, prüfung, verschiedenes)
        - if no category fits extacty, find out what type the document is
        - Use "unknown" for unclear values
        - No additional text or explanations.
        - Focus on accuracy and maintain the exact JSON structure

        Return ONLY a JSON object with this structure:
        {
          "sender_name": "Company or person who sent the document",
          "receiver_name": "Company or person receiving the document",
          "main_date": "Main document date in YYYY-MM-DD format",
          "category": "Document category in German"
        }
        TEXT
    end
  end
end
