# frozen_string_literal: true

module Raider
  module Llms
    class Phi4 < Base
      def default_options
        {
          temperature: 0.25, # Balanced temperature for analysis
          top_p: 0.75,            # Focused sampling for reliable results
          top_k: 35,              # Conservative diversity setting
          max_tokens: 900,        # Adequate token count for analysis
          repeat_penalty: 1.08,    # Minimal repetition penalty
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
    end
  end
end
