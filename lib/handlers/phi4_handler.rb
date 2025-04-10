require_relative 'base_handler'
require_relative '../prompts/phi4_prompt'

module Handlers
  class Phi4Handler < Base
    def initialize
      @prompt = Prompts::Phi4Prompt.new
      @llm = Langchain::LLM::Ollama.new(
        default_options: {
          chat_model: "phi4:latest",
          temperature: 0.1,
          num_predict: 512,
          top_k: 10,
          top_p: 0.1
        }
      )
    end

    def analyze_document(image)
      b64 = base64_encode(image)
      messages = [{
        role: "user",
        content: @prompt.to_document_infos,
        images: [b64],
        response_format: "json"
      }]

      response = @llm.chat(messages: messages)
      content = response.raw_response.dig('message', 'content')
      json_str = extract_json_from_text(content)
      parse_json_safely(json_str)
    end
  end
end
