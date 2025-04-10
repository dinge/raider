require_relative 'base_handler'
require_relative '../prompts/llama3_prompt'

module Handlers
  class Llama3Handler < Base
    def initialize(context = {})
      @prompt = Prompts::Llama3Prompt.new(context)
      @llm = Langchain::LLM::Ollama.new(
        default_options: {
          chat_model: "llama3.2-vision:11b",
          temperature: 0.1,
          response_format: "json"
        }
      )
    end

    def analyze_document(image)
      b64 = base64_encode(image)
      messages = [{
        role: "user",
        content: @prompt.to_document_infos,
        images: [b64],
        format: "json"
      }]

      response = @llm.chat(messages: messages)
      JSON.parse(response.raw_response.dig('message', 'content'))
    end
  end
end