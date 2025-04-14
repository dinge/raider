module Raider
  module Providers
    class Base
      def self.provider_ident = name.split('::').last.underscore
      def provider_ident = self.class.provider_ident
      def self.available = (Raider::Providers.constants - [:Base]).map { Raider::Providers.const_get(_1).provider_ident }

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
          system: "You are a helpful agent."
        }
      end
    end
  end
end
