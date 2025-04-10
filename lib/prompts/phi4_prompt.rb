require_relative 'base_prompt'

module Prompts
  class Phi4Prompt < Base
    def to_document_infos
      format_template(TEMPLATE)
    end

    private

    TEMPLATE = <<~TEXT
      Task: Extract key information from this document image into a JSON format.

      Required format:
      {
        "sender_name": "who sent the document",
        "receiver_name": "who received the document",
        "main_date": "date in YYYY-MM-DD format",
        "category": "document type in German ({{categories}})"
      }

      Rules:
      1. Only look at visible text in the image
      2. Use "Unknown" if information isn't clear
      3. Return only the JSON object
      4. Make sure the JSON is properly formatted
      5. For category, only use the allowed German terms listed above

      Analyze the image and respond with only the JSON object.
    TEXT
  end
end
