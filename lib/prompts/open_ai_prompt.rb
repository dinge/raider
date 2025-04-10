require_relative 'base_prompt'

module Prompts
  class OpenAiPrompt < Base
    def to_document_infos
      format_template(TEMPLATE)
    end

    private

    TEMPLATE = <<~TEXT
      Analyze this document image and return ONLY a JSON object with these fields:
      {
        "sender_name": "Company or person who sent the document",
        "receiver_name": "Company or person receiving the document",
        "main_date": "Main document date in YYYY-MM-DD format",
        "category": "Document category in German (e.g. {{categories}})"
      }
      Respond only with valid JSON. Do not write an introduction or summary.
      Do not include any additional information or comments. Do just return the JSON object without markdown other wrappers
    TEXT
  end
end