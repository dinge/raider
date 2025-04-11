module Raider
  module Handlers
    class TogetherLlama3Handler < Base
      def initialize
        @prompt = Prompts::TogetherLlama3Prompt.new
        @llm = Langchain::LLM::OpenAI.new(
          api_key: ENV["TOGETHER_API_KEY"],
          llm_options: {
            uri_base: "https://api.together.xyz/v1"
          },
          default_options: {
            model: 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo',
            chat_model: 'meta-llama/Llama-3.2-90B-Vision-Instruct-Turbo',
            temperature: 0.1
          }
        )
      end

      def analyze_document(image)
        b64 = base64_encode(image)
        messages = [{
          role: "user",
          content: [
            { type: "text", text: @prompt.analyze_document },
            { type: "image_url", image_url: { url: "data:image/jpeg;base64,#{b64}" } }
          ]
        }]

        response = @llm.chat(messages: messages)
        content = response.raw_response.dig('choices').first.dig('message', 'content')
        parse_json_safely(content)
      end
    end
  end
end
