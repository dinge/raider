require_relative '../prompts/document_analysis'

module Handlers
  class Base
    def analyze_document(image)
      raise NotImplementedError
    end

    protected

    def base64_encode(image)
      Base64.strict_encode64(File.binread(image))
    end

    def extract_json_from_text(text)
      if match = text.match(/\{.*\}/m)
        match[0]
      else
        "{}"
      end
    end

    def parse_json_safely(str)
      JSON.parse(str)
    rescue JSON::ParserError
      {
        "sender_name" => "Unknown",
        "receiver_name" => "Unknown",
        "main_date" => "",
        "category" => "misc"
      }
    end
  end
end