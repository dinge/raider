module Prompts
  class Base
    attr_reader :context

    def initialize(context = {})
      @context = context
    end

    def to_document_infos
      raise NotImplementedError, "#{self.class} must implement #to_document_infos"
    end

    protected

    def format_template(template)
      template.gsub(/\{\{(\w+)\}\}/) do |match|
        key = $1
        context.fetch(key.to_sym, match)
      end
    end
  end
end