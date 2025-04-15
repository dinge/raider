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
          tools: %w[vision]
        }
      end
    end
  end
end
