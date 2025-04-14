# frozen_string_literal: true

module Raider
  module Llms
    class Base
      def initialize(app:, provider:)
        @app = app
        @provider = provider
      end

      def self.llm_ident = name.split('::').last.underscore
      delegate :llm_ident, to: :class

      def self.available = (Raider::Llms.constants - [:Base]).map { Raider::Llms.const_get(it).llm_ident }

      def llm_options
        { default_options: }
      end

      def default_options
        {
          format: 'json'
        }
      end
    end
  end
end
