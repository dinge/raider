# frozen_string_literal: true

module Raider
  module Providers
    class OpenAi < Base
      MODELS = {
        gpt4_1: {
          chat_model: 'gpt-4.1'
        },
        gpt4o_mini: {
          chat_model: 'gpt-4o-mini'
        },
        gpt41_mini: {
          chat_model: 'gpt-4o-mini'
        },
        gpt4: {
          chat_model: 'gpt-4'
        },
        o1_mini: {
          chat_model: 'o1-mini'
        },
        o3_mini: {
          chat_model: 'o3-mini'
        },
        gpt5: {
          chat_model: 'gpt-5'
        },
        gpt5_mini: {
          chat_model: 'gpt-5-mini'
        },
        gpt5_nano: {
          chat_model: 'gpt-5-nano'
        },
      }.freeze

      def ruby_llm_client_class
        Langchain::LLM::OpenAI
      end

      def provider_options
        { api_key: ENV.fetch('OPENAI_API_KEY', nil),
          default_options: }
      end

      def default_options
        # { chat_model: default_model,
        #   temperature: 0.1 }
        { chat_model: default_model,
          request_timeout: 240 }
      end

      def to_messages_basic_to_json(prompt:)
        to_message_with do
          [{
            role: 'user',
            content: [
              { type: 'text', text: prompt }
            ],
            response_format: :json_object
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
            response_format: :json_object
          }]
        end
      end

      def parse_raw_response(raw_response)
        raw_response.dig('choices', 0, 'message', 'content')
      end

      def parse_tool_calls(raw_response)
        # dig("choices", 0, "message", 'role') == 'assistant'
        raw_response.dig('choices', 0, 'message', 'tool_calls')
      end

      def parse_usage(raw_response)
        raw_response.dig('usage')
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
