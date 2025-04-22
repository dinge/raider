# frozen_string_literal: true

module Raider
  module Apps
    class Base
      attr_accessor :config, :llm, :provider, :llm_class

      def initialize(config)
        @config = config
      end

      def app_ident = self.class.name.split('::').last.underscore

      def pdf_files
        Dir.glob(File.join(@config[:input_directory], '*.pdf'))
      end

      def create_task(task, llm: nil, provider: nil)
        @provider = "Raider::Providers::#{provider || @config[:provider].classify}".constantize.new
        llm_class_name = (llm || @config[:llm] || @provider.default_llm_ident).to_s.classify
        @llm_class = if Raider::Llms.const_defined?(llm_class_name)
                       Raider::Llms.const_get(llm_class_name)
                     else
                       Raider::Llms::Dummy
                     end
        @llm = @llm_class.new(app: self, provider: @provider)
        Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider).process(task)
      end

      def create_agent(agent, llm: nil, provider: nil)
        @provider = "Raider::Providers::#{provider || @config[:provider].classify}".constantize.new
        llm_class_name = (llm || @config[:llm] || @provider.default_llm_ident).to_s.classify
        @llm = "Raider::Llms::#{llm_class_name}".constantize.new(app: self, provider: @provider)
        Runners::AgentRunner.new(app: self, llm: @llm, provider: @provider).process(agent)
      end

      # def create_task(task, llm: nil, provider: nil)
      #   run_with_setup(llm:, provider:) do
      #     Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider).process(task)
      #   end
      # end

      # def run_with_setup(llm:, provider:)
      #   p = "Raider::Providers::#{provider || @config[:provider].classify}".constantize.new
      #   llm_class_name = (llm || @config[:llm] || p.default_llm_ident).to_s.classify
      #   l= "Raider::Llms::#{llm_class_name}".constantize.new(app: self, provider: p)
      #   Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider).process(task)
      # end

      def dump(entry) = puts JSON.pretty_generate(entry)
    end
  end
end
