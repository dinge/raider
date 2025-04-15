# frozen_string_literal: true

module Raider
  module Llms
    class Llama3v2VisionSmall < Base
      def default_options
        {
          temperature: 0.2, # Slightly higher temperature for balanced analysis
          top_p: 0.8,             # Balanced sampling for reliable outputs
          top_k: 45,              # Moderate diversity setting
          max_tokens: 1000,       # Sufficient tokens for analysis
          repeat_penalty: 1.12,    # Light repetition penalty
          vision_config: {
            temperature: 0.15,     # Slightly higher vision temperature
            image_resolution: 'medium', # Balanced resolution setting
            detail_level: 'balanced', # Balanced detail processing
            visual_tokens: 768 # Moderate visual token count
          },
          context: {
            window_size: 4096,     # Standard context window
            overlap: 64            # Minimal context overlap
          }
        }
      end
    end
  end
end
