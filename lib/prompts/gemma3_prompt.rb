require_relative 'base_prompt'

module Prompts
  class Gemma3Prompt < Base
    def analyze_document
      <<~TEXT
        You are an expert document analyzer. Extract these specific details:

        1. Sender: Who sent this document? (Look at letterhead or signature)
        2. Receiver: Who is this document for? (Look at recipient details)
        3. Date: What is the main document date?
        4. Type: What kind of document is this? (Must be one of: #{context[:categories]})

        Return only a JSON object with this exact structure:
        {
          "sender_name": "<extracted sender>",
          "receiver_name": "<extracted receiver>",
          "main_date": "<date in YYYY-MM-DD>",
          "category": "<one of the document types listed above>"
        }

        Important:
        - Respond with ONLY the JSON object
        - Use YYYY-MM-DD format for dates
        - For category, only use the listed German terms
        - Use "Unknown" for unclear names, empty string for unclear dates
      TEXT
    end
  end
end
