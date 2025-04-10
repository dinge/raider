module Raider
  module Handlers
    class OpenAiHandler < Base
      def initialize
        @prompt = Prompts::OpenAiPrompt.new
        @llm = Langchain::LLM::OpenAI.new(
          api_key: ENV["OPENAI_API_KEY"],
          default_options: { model: 'gpt-4', temperature: 0.1 }
        )
      end

      def analyze_document(image)
        b64 = base64_encode(image)
        messages = [{
          role: "user",
          content: [
            { type: "text", text: @prompt.analyze_document },
            { type: "image_url", image_url: { url: "data:image/png;base64,#{b64}" } }
          ]
        }]

        response = @llm.chat(messages: messages)
        content = response.raw_response.dig('choices').first.dig('message', 'content')
        parse_json_safely(content)
      end
    end
  end
end