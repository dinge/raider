module Raider
  module Handlers
    class Phi4Handler < Base
      def initialize
          @llm = Langchain::LLM::Ollama.new(
          default_options: {
            chat_model: "phi4:latest",
            temperature: 0.1,
            num_predict: 512,
            top_k: 10,
            top_p: 0.1,
            system: "You are a document analysis expert, your goal is to analyze documents and provide insights.
                     You have to respond only in JSON format.",
            format: 'json'
          }
        )
      end

      def analyze_document(image)
        b64 = base64_encode(image)
        messages = [{
          role: "user",
          content: @prompt.analyze_document,
          images: [b64],
          response_format: "json"
        }]

        response = @llm.chat(messages: messages)
        content = response.raw_response.dig('message', 'content')
        parse_json_safely(content)
      end
    end
  end
end
