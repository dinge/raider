module Raider
  module Handlers
    class Gemma3Handler < Base
      def initialize
          @llm = Langchain::LLM::Ollama.new(
          default_options: {
            chat_model: "gemma3:12b",
            temperature: 0.1,
            num_predict: 512,
            system: "You are a document analysis expert, your goal is to analyze documents and provide insights.
                     You have to respond only in JSON format.",
            format: 'json'
          }
        )
      end
    end
  end
end
