module Raider
  module Handlers
    class Base
      attr_reader :llm

      protected

      def base64_encode(image)
        Base64.strict_encode64(File.binread(image))
      end

      def parse_json_safely(str)
        json_match = str.match(/\{.*\}/m)
        json_match ? JSON.parse(json_match[0]) : { message: str }
      rescue JSON::ParserError => e
        {
          "error" => e.message,
          "sender_name" => "unknown",
          "receiver_name" => "unknown",
          "main_date" => "unknown",
          "category" => "unknown"
        }
      end
    end
  end
end
