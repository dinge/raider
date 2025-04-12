module Raider
  module Tasks
    class Base
      attr_accessor :context

      def initialize(handler:)
        @llm = handler.llm
        #@context = context
      end

      private

      def chat_message_with_image(prompt, image)
        b64 = base64_encode(image)

        # messages = [{
        #   role: "user",
        #   content: [
        #     { type: "text", text: prompt },
        #     { type: "image_url", image_url: { url: "data:image/png;base64,#{b64}" } }
        #   ]
        # }]

        messages = [{
          role: "user",
          content: prompt,
          images: [b64],
          response_format: "json"
        }]



        parse_response(@llm.chat(messages: messages))
      end


      def parse_response(response)
        response_message = response.raw_response.dig('choices')&.first&.dig('message', 'content') || response.raw_response.dig('message', 'content')
        parse_json_safely(response_message)
      end

      def base64_encode(image) = Base64.strict_encode64(File.binread(image))

      def parse_json_safely(str)
        json_match = str.match(/\{.*\}/m)
        json_match ? JSON.parse(json_match[0]) : { llm_message: str }
      rescue JSON::ParserError => e
        {
          "error" => e.message,
          "llm_message" => str
        }
      end
    end
  end
end
