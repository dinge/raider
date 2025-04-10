require_relative 'base_handler'
require_relative '../prompts/llama3_prompt'

module Handlers
  class Llama3Handler < Base
    def initialize
      @prompt = Prompts::Llama3Prompt.new
      @llm = Langchain::LLM::Ollama.new(
        default_options: {
          chat_model: "llama3.2-vision:11b",
          temperature: 0.1,
          system: "You are a document analysis expert, your goal is to analyze documents and provide insights.",
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
