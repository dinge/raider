# frozen_string_literal: true

module Raider
  module Llms
    class UnslothQwen2v5Vl32bQ4 < Base
      def default_options
        {
          temperature: 0.1 # Lower temperature for more deterministic outputs in document analysis
          #   top_p: 0.7,              # Slightly restricted sampling for more focused responses
          #   top_k: 40,               # Reasonable diversity while maintaining reliability
          #   max_tokens: 1024,        # Sufficient for detailed document analysis output
          #   repeat_penalty: 1.1,     # Slight penalty to avoid repetitive text in descriptions
          #   stop_sequences: ['}'],   # Ensure clean JSON cutoff
          #   context_window: 4096,    # Good balance for document context
          #   vision: {
          #     temperature: 0.1,      # Low temperature for accurate vision analysis
          #     image_quality: 'high', # Maximum quality for document details
          #     image_model: 'default' # Default vision model is sufficient for documents
          #   }
        }
      end
    end
  end
end
