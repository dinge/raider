require_relative 'base_prompt'

module Prompts
  class Llama3Prompt < Base
    def to_document_infos
      format_template(TEMPLATE)
    end

    private

    TEMPLATE = <<~TEXT
      As a document analysis expert, analyze this image and extract:

      1. The sender (from letterhead, company logo, or sender details)
      2. The recipient (from address block or recipient field)
      3. The primary document date
      4. The document type in German (valid types: {{categories}})

      Return ONLY a JSON object with this structure:
      {
        "sender_name": "Company or person who sent the document",
        "receiver_name": "Company or person receiving the document",
        "main_date": "Main document date in YYYY-MM-DD format",
        "category": "Document category in German"
      }

      Focus on accuracy and maintain the exact JSON structure. No additional text or explanations.
    TEXT
  end
end