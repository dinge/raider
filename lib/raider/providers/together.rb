# frozen_string_literal: true

module Raider
  module Providers
    class Together < Base
      MODELS = {
        llama3v2_vision_large: {
          model: 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo',
          chat_model: 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo'
        }
      }.freeze

      def client_class
        Langchain::LLM::OpenAI
      end

      def provider_options
        { api_key: ENV.fetch('TOGETHER_API_KEY', nil),
          llm_options: {
            uri_base: 'https://api.together.xyz/v1'
          },
          default_options: }
      end

      def default_options
        {
          model: default_model,
          chat_model: default_model,
          temperature: 0.1
        }
      end

      def to_messages_basic_with_images_to_json(prompt:)
        [{
          role: 'user',
          content: [
            { type: 'text', text: prompt }
          ]
        }]
      end

      def to_messages_basic_with_images_to_json(prompt:, images:)
        [{
          role: 'user',
          content: [
            { type: 'text', text: prompt },
            { type: 'image_url', image_url: { url: "data:image/png;base64,#{images.first}" } }
          ]
        }]
      end

      def parse_raw_response(raw_response)
        raw_response['choices']&.first&.dig('message', 'content')
      end
    end
  end
end
