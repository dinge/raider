# frozen_string_literal: true

module Raider
  module Providers
    class Base
      attr_accessor :system_prompt

      def initialize
        @system_prompt = nil
      end

      def self.provider_ident = name.split('::').last.underscore
      delegate :provider_ident, to: :class

      def self.available
        (Raider::Providers.constants - [:Base]).map do
          Raider::Providers.const_get(it).provider_ident
        end
      end

      def default_llm_ident = self.class::MODELS.keys.first

      def default_model = self.class::MODELS.values.first[:chat_model]
      def ruby_llm_client_class = raise NotImplementedError

      def llm_options_by_ident(llm)
        { default_options: self.class::MODELS[llm.llm_ident.to_sym] }
      end

      def provider_options
        { default_options: }
      end

      def default_options
        {
          system: 'You are a helpful agent.'
        }
      end

      def to_message_with
        yield.tap do |messages|
          messages.unshift(system_prompt_template) if system_prompt
        end
      end

      def system_prompt_template
        {
          role: 'system',
          content: system_prompt
        }
      end

      def parse_raw_response(raw_response)
        { raw_response: }
      end

      def parse_tool_calls(raw_response)
        {}
      end

      def parse_usage(raw_response)
        {}
      end
    end
  end
end
