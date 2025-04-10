module Raider
  module Prompts
    class Base
      attr_reader :context

      def initialize(context = {})
        @context = context
      end

      def analyze_document
        raise NotImplementedError
      end
    end
  end
end
