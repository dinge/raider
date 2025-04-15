# frozen_string_literal: true

module Raider
  module Providers
    class Together < Base
      MODELS = {
        llama3v2_vision_large: {
          model: 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo',
          chat_model: 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo'
        },
        llama3v2_vision_small: {
          model: 'meta-llama/Llama-3.2-11B-Vision-Instruct-Turbo',
          chat_model: 'meta-llama/Llama-3.2-11B-Vision-Instruct-Turbo'
        },
        llama3v2_vision_free: {
          model: 'meta-llama/Llama-Vision-Free"',
          chat_model: 'meta-llama/Llama-Vision-Free"'
        },
        qwen2v5_vl_large: {
          model: 'Qwen/Qwen2-VL-72B-Instruct',
          chat_model: 'Qwen/Qwen2-VL-72B-Instruct'
        },
        qwen2_vl_large: {
          model: 'Qwen/Qwen2.5-VL-72B-Instruct',
          chat_model: 'Qwen/Qwen2.5-VL-72B-Instruct'
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
        to_message_with do
          [{
            role: 'user',
            content: [
              { type: 'text', text: prompt }
            ],
            response_format: :json
          }]
        end
      end

      def to_messages_basic_with_images_to_json(prompt:, images:)
        to_message_with do
          [{
            role: 'user',
            content: [
              { type: 'text', text: prompt },
              { type: 'image_url', image_url: { url: "data:image/png;base64,#{images.first}" } }
            ],
            response_format: :json
          }]
        end
      end

      def parse_raw_response(raw_response)
        raw_response['choices']&.first&.dig('message', 'content')
      end
    end
  end
end
