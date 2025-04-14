# frozen_string_literal: true

module Raider
  module Llms
    class Qwen2VlSmall < Base
      def default_options
        {
          temperature: 0.18,       # Balanced temperature for reliable analysis
          top_p: 0.82,            # Good balance for sampling
          top_k: 42,              # Moderate diversity
          max_tokens: 1200,       # Generous token count for analysis
          repeat_penalty: 1.1,     # Standard repetition penalty
          system_message: document_analysis_system_message,
          vision_settings: {
            temperature: 0.12,     # Low vision temperature for accuracy
            resolution: "high",    # High resolution for documents
            detail_mode: "text_focus", # Focus on text in documents
            token_limit: 896       # Balanced visual token limit
          },
          processing: {
            batch_size: 1,        # Process one document at a time
            timeout: 30           # Reasonable timeout for analysis
          }
        }
      end

      private

      def document_analysis_system_message
        <<~SYSTEM
          You are a document analysis expert specializing in:
          - Business document processing
          - Layout and structure analysis
          - Information extraction
          - Multi-language handling
          
          Key functions:
          1. Document content analysis
          2. Data extraction and standardization
          3. Language-aware processing
          4. Structured information output
          
          Return all responses in JSON format.
        SYSTEM
      end
    end
  end
end
