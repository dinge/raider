# frozen_string_literal: true

module Raider
  module Llms
    class Llama3v2VisionLarge < Base
      def default_options
        {
          temperature: 0.15, # Balanced temperature for reliable analysis
          top_p: 0.85,            # Good balance of focus and flexibility
          top_k: 50,              # Moderate diversity for robust analysis
          max_tokens: 4096,       # Higher token count for detailed analysis
          repeat_penalty: 1.15,    # Moderate repetition prevention
          system_message: document_analysis_system_message,
          vision_config: {
            temperature: 0.1,      # Low temperature for vision accuracy
            image_resolution: 'high', # High resolution for document details
            detail_level: 'auto',    # Automatic detail level adjustment
            visual_tokens: 1024      # Good balance for visual analysis
          },
          context: {
            window_size: 8192,     # Large context window for document understanding
            overlap: 128           # Context overlap for coherence
          }
        }
      end

      private

      def document_analysis_system_message
        <<~SYSTEM
          You are an advanced document analysis system with expertise in:
          - Complex document layout understanding
          - Multi-modal business document processing
          - Detailed information extraction
          - Cross-language document handling

          Your primary functions:
          1. Analyze document structure and content
          2. Extract key business information
          3. Process multiple languages accurately
          4. Maintain consistent output format

          Always provide responses in valid JSON format.
        SYSTEM
      end
    end
  end
end
