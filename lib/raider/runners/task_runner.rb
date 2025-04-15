# frozen_string_literal: true

module Raider
  module Runners
    class TaskRunner
      attr_reader :response, :response_message, :app, :llm, :provider, :system_prompt, :current_task

      def initialize(app:, llm:, provider:)
        @app = app
        @llm = llm
        @provider = provider
        # @context = context

        @current_task_class = nil
        @current_task = nil
        @system_prompt = 'You are a helpful agent.'
      end

      def process(task)
        @current_task_class = Raider::Tasks.const_get(task.to_s.classify)
        if @current_task_class.const_defined?(@llm.llm_ident.to_s.classify)
          @current_task_class = @current_task_class.const_get(@llm.llm_ident.to_s.classify)
        end
        @current_task = @current_task_class.new(task_runner: self, app:, llm:, provider:)
      end

      def llm_chat(**args)
        # puts args[:messages].first[:content].first
        client.chat(**args)
      end

      def client
        @provider.client_class.new(**build_current_client_options)
      end

      def build_current_client_options
        @provider.provider_options
                 .deep_merge(@provider.llm_options_by_ident(@llm))
                 .deep_merge(@llm.llm_options)
                 .deep_merge(@current_task.llm_options)
      end

      def set_system_prompt(system_prompt)
        @system_prompt = system_prompt
      end

      def chat(prompt, system_prompt: nil)
        @provider.system_prompt = system_prompt || @system_prompt
        messages = @provider.to_message_basic_to_json(prompt:)
        parse_response(llm_chat(messages: messages))
      end

      def chat_message_with_images(prompt, images, system_prompt: nil)
        images = images.map { base64_encode(it) }
        @provider.system_prompt = system_prompt || @system_prompt
        messages = @provider.to_messages_basic_with_images_to_json(prompt:, images:)
        parse_response(llm_chat(messages: messages))
      end

      def parse_response(response)
        @response = response
        @response_message = @provider.parse_raw_response(@response.raw_response)
        parse_json_safely(@response_message).tap do |json_response|
          log_response(@response.raw_response, json_response)
        end
      end

      def parse_json_safely(str)
        json_match = str.match(/\{.*\}/m)
        json_match ? JSON.parse(json_match[0]) : { llm_message: str }
      rescue JSON::ParserError => e
        { error_message: e.message,
          llm_message: str }
      end

      def log_response(raw_response, json_response)
        FileUtils.mkdir_p('logs')

        entry = {
          timestamp: Time.now.iso8601,
          config: @app.config,
          raw_response:,
          json_response:
        }

        puts JSON.pretty_generate(entry) if @app.config[:debug]

        log_file = "logs/#{@app.app_ident}--#{@llm.llm_ident}-#{@provider.provider_ident}.log"
        File.open(log_file, 'a') do |f|
          f.puts [entry].to_yaml
        end
      end

      def base64_encode(image) = Base64.strict_encode64(File.binread(image))
    end
  end
end
