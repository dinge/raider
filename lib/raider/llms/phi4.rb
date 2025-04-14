# frozen_string_literal: true

module Raider
  module Llms
    class Phi4 < Base
      def default_options
        {
          temperature: 0.25,       # Balanced temperature for analysis
          top_p: 0.75,            # Focused sampling for reliable results
          top_k: 35,              # Conservative diversity setting
          max_tokens: 900,        # Adequate token count for analysis
          repeat_penalty: 1.08,    # Minimal repetition penalty
          system_message: document_analysis_system_message,
          format_options: {
            json_mode: true,       # Force JSON output
            schema_validation: true # Enable schema validation
          },
          processing: {
            chunk_size: 512,      # Moderate chunk size for processing
            overlap: 32           # Small overlap for context
          }
        }
      end

      private

      def document_analysis_system_message
        <<~SYSTEM
          You are a specialized document analyzer with focus on:
          - Precise information extraction
          - Business document understanding
          - Structured data output
          - Multi-language processing
          
          Primary tasks:
          1. Extract key document information
          2. Classify document types
          3. Process business correspondence
          4. Handle multiple languages
          
          All outputs must be in JSON format.
        SYSTEM
      end
    end
  end
end
