# frozen_string_literal: true

module Raider
  module Llms
    class Gpt4oMini < Base
      def default_options
        {
          temperature: 0.05,        # Very low temperature for highest accuracy in document analysis
          top_p: 0.9,               # Allow some flexibility while maintaining focus
          max_tokens: 4096,         # Balanced token count for document descriptions
          presence_penalty: 0.0,    # Neutral presence penalty for factual extraction
          frequency_penalty: 0.1,   # Slight penalty to avoid repetitive terms
          system_message: document_analysis_system_message,
          tools: %w[vision]
        }
      end

      private

      def document_analysis_system_message
        <<~SYSTEM
          You are a document analysis expert specialized in:
          - Business document understanding and classification
          - Multi-language processing (German/English)
          - Precise information extraction
          - Format standardization

          Key responsibilities:
          1. Extract document metadata (dates, parties, types)
          2. Identify document structure and purpose
          3. Handle multiple document layouts
          4. Maintain high accuracy in data extraction

          All responses must be in JSON format.
        SYSTEM
      end
    end
  end
end
