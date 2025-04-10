require_relative 'base_prompt'

module Prompts
  class Qwen2Prompt < Base
    def to_document_infos
      format_template(TEMPLATE)
    end

    private

    TEMPLATE = <<~TEXT
      You are a document analysis assistant. Analyze this document image and extract:

      1. Sender: Look for the letterhead, company logo, or sender details at the top
      2. Receiver: Find the recipient's details in the address block
      3. Date: Locate the primary document date (usually near the top)
      4. Category: Determine document type from: {{categories}}

      Important rules:
      - Return ONLY a JSON object without any other text
      - Use exactly these keys: "sender_name", "receiver_name", "main_date" (YYYY-MM-DD format), "category"
      - For dates, only return the main document date in YYYY-MM-DD format
      - For category, only use one of these German terms: {{categories}}
      - If you're unsure about any field, use "Unknown" for names, empty string for date, and "misc" for category

      Example format:
      {"sender_name": "Company GmbH", "receiver_name": "Client AG", "main_date": "2024-02-20", "category": "Rechnung"}
    TEXT
  end
end
