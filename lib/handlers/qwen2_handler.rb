require_relative 'base_handler'
require_relative '../prompts/qwen2_prompt'

module Handlers
  class Qwen2Handler < Base
    def initialize
      @prompt = Prompts::Qwen2Prompt.new
      @llm = Langchain::LLM::Ollama.new(
        default_options: {
          chat_model: "siasi/qwen2-vl-7b-instruct:latest",
          temperature: 0.1,
          num_predict: 512,
          top_p: 0.9
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
      parse_json_safely(content)
    end
  end
end
