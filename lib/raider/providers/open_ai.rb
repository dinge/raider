module Raider
  module Providers
    class OpenAi < Base

      MODELS = {
        gpt_4o_mini: {
          chat_model: "gpt-4o-mini"
        },
        gpt_4: {
          chat_model: "gpt-4"
        },
        o1_mini: {
          chat_model: "o1-mini"
        }
      }

      def client_class
        Langchain::LLM::OpenAI
      end

      def provider_options
        { api_key: ENV["OPENAI_API_KEY"],
          default_options: }
      end

      def default_options
        { model: default_model,
          temperature: 0.1 }
      end


      def to_messages_basic_with_images_to_json(prompt:)
        [{
          role: "user",
          content: [
            { type: "text", text: prompt },
          ]
        }]
      end

      def to_messages_basic_with_images_to_json(prompt:, images:)
        [{
          role: "user",
          content: [
            { type: "text", text: prompt },
            { type: "image_url", image_url: { url: "data:image/png;base64,#{images.first}" } }
          ]
        }]
      end

      def parse_raw_response(raw_response)
        raw_response.dig('choices')&.first&.dig('message', 'content')
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
