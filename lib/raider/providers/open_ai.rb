# frozen_string_literal: true

module Raider
  module Providers
    class OpenAi < Base
      MODELS = {
        gpt4o_mini: {
          chat_model: 'gpt-4o-mini'
        },
        gpt4: {
          chat_model: 'gpt-4'
        },
        o1_mini: {
          chat_model: 'o1-mini'
        }
      }.freeze

      def client_class
        Langchain::LLM::OpenAI
      end

      def provider_options
        { api_key: ENV.fetch('OPENAI_API_KEY', nil),
          default_options: }
      end

      def default_options
        { model: default_model,
          temperature: 0.1 }
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

# messages = [{
#   role: "user",
#   content: [
#     { type: "text", text: prompt },
#     { type: "image_url", image_url: { url: "data:image/png;base64,#{b64}" } }
#   ]
# }]
