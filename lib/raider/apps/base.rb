# frozen_string_literal: true

module Raider
  module Apps
    class Base
      class_attribute :provider, default: :open_ai
      class_attribute :llm

      attr_accessor :app_context
      attr_accessor :llm_class

      alias context app_context

      def app = self

      delegate :input, :inputs, :output, :outputs, to: :app_context
      delegate :dump_tasks, :dump_full_tasks, to: :app_context

      def initialize(input_context = {})
        @upstream = input_context.extract!(:upstream)
        @app_context = Utils::AppContext.new(input_context.reverse_merge(default_context))

        @current_agents = []
        @with_app_persistence = @app_context.with_app_persistence
        @app_persistence = nil
        Raider.logger.level = Logger::DEBUG if @app_context.debug || ENV['DEBUG'] == 'true'
      end

      def default_context
        { debug: true,
          provider:,
          llm: nil,
          agents: [],
          # data: {},
          input: nil,
          inputs: nil,
          output: nil,
          outputs: {},
          processor_class: nil,
          with_app_persistence: false,
          }
      end

      def app_class_name = self.class.name.split('::').last
      def app_ident = app_class_name.underscore

      def pdf_files
        Dir.glob(File.join(@app_context.input_path, '**/*.pdf')).shuffle
      end

      # basic task run without context management
      def create_task(task_ident, llm: nil, provider: nil, agent: nil)
        init_llm_setup!(provider, llm)
        Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider, agent:).process(task_ident)
      end

      def run_agent(agent_ident, llm: nil, provider: nil, input: nil, &proc)
        Raider.log(start_agent: agent_ident, provider:, llm:)

        agent = create_agent(agent_ident, llm:, provider:, input:)
        agent_runner = agent.process(&proc)
        Raider.log(stop_agent: agent_ident)

        app.context.agents << { agent_ident.to_sym => agent_runner.current_context.to_hash }
        agent_runner
      end




      def create_agent(agent_ident, llm: nil, provider: nil, input: nil)
        init_llm_setup!(provider, llm)
        start_app_persistence! if @with_app_persistence
        Runners::AgentRunner.new(app: self, llm: @llm, provider: @provider).process(agent_ident, input:)
      end

      def start_app_persistence!
        # title = "#{self.class.name.split('::').last} | #{upstream.id} - #{DateTime.now.to_fs(:long)} - #{self.class::LLM}"

        reference = case @upstream
          when Raider::Source
            { source: upstream, upstream: }
          when Raider::App
            { parent_app: upstream, upstream: }
          else
            { source: Raider::Source.first, upstream: Raider::Source.first }
          end

        title = [app_class_name, DateTime.now.to_fs(:long), @app_context.llm].join(' / ')
        Raider::App.create!(
          { title:,
            llm: @app_context.llm,
            provider: @app_context.provider,
            processor_class: @app_context.processor_class,
            raider_app_class: self.class.name,
            started_at: DateTime.now.utc }.merge(reference)
        )
      end


      ## TODO: move to AppRunner

      def init_llm_setup!(provider, llm)
        init_provider(provider)
        init_llm_class(llm)
        init_llm
      end

      def init_provider(provider)
        @provider = "Raider::Providers::#{provider || @app_context.provider.to_s.camelize}".constantize.new
      end

      def init_llm
        @llm = @llm_class.new(app: self, provider: @provider)
      end

      def init_llm_class(llm)
        llm_class_name = (llm || @app_context.llm || @provider.default_llm_ident).to_s.camelize
        @llm_class = if Raider::Llms.const_defined?(llm_class_name)
                       Raider::Llms.const_get(llm_class_name)
                     else
                       Raider::Llms.const_get(llm_class_name)
                       # Raider::Llms::Dummy
                     end
      end

      def dump(entry) = puts JSON.pretty_generate(entry)

      # def create_task(task, llm: nil, provider: nil)
      #   run_with_setup(llm:, provider:) do
      #     Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider).process(task)
      #   end
      # end

      # def run_with_setup(llm:, provider:)
      #   p = "Raider::Providers::#{provider || @app_context[:provider].camelize}".constantize.new
      #   llm_class_name = (llm || @app_context[:llm] || p.default_llm_ident).to_s.camelize
      #   l= "Raider::Llms::#{llm_class_name}".constantize.new(app: self, provider: p)
      #   Runners::TaskRunner.new(app: self, llm: @llm, provider: @provider).process(task)
      # end
    end
  end
end
