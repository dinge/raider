module Raider
  module Tasks
    class DescribeImage < Base
      def process(image)
        chat_message_with_images(prompt, [image])
      end

      def prompt
        <<~TEXT
          describe all what you see, think deeply
          #{json_instruct}
        TEXT
      end
    end
  end
end
