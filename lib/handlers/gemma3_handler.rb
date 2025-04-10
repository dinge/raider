require_relative 'base_handler'
require_relative '../prompts/gemma3_prompt'

module Handlers
  class Gemma3Handler < Base
    def initialize
      @prompt = Prompts::Gemma3Prompt.new
      @llm = Langchain::LLM::Ollama.new(
        default_options: {
          chat_model: "gemma3:12b",
          temperature: 0.1,
          num_predict: 512,
          system: "You are a document analysis expert that always responds in valid JSON format."
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
