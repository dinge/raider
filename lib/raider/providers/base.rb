# frozen_string_literal: true

module Raider
  module Providers
    class Base
      def self.provider_ident = name.split('::').last.underscore
      delegate :provider_ident, to: :class

      def self.available = (Raider::Providers.constants - [:Base]).map do
        Raider::Providers.const_get(it).provider_ident
      end

      def default_llm_ident = self.class::MODELS.keys.first
      def default_model = self.class::MODELS.values.first[:chat_model]
      def client_class = raise NotImplementedError

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
    end
  end
end
