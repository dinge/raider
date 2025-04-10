module Prompts
  class Base
    attr_reader :context

    def initialize(context = {})
      @context = context
    end

    def analyze_document
      raise NotImplementedError, "#{self.class} must implement #to_document_infos"
    end
  end
end
