# frozen_string_literal: true

module Raider
  module Llms
    class Gemma3Small < Base
      def default_options
        {
          temperature: 0.1,         # Lower temperature for more deterministic outputs in document analysis
          top_p: 0.7,              # Slightly restricted sampling for more focused responses
          top_k: 40,               # Reasonable diversity while maintaining reliability
          max_tokens: 1024,        # Sufficient for detailed document analysis output
          repeat_penalty: 1.1,     # Slight penalty to avoid repetitive text in descriptions
          system_message: document_analysis_system_message,
          stop_sequences: ["}"],   # Ensure clean JSON cutoff
          context_window: 4096,    # Good balance for document context
          vision: {
            temperature: 0.1,      # Low temperature for accurate vision analysis
            image_quality: "high", # Maximum quality for document details
            image_model: "default" # Default vision model is sufficient for documents
          }
        }
      end

      private

      def document_analysis_system_message
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
