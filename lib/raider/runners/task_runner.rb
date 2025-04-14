module Raider
  module Runners
    class TaskRunner
      attr_reader :response, :response_message, :app, :llm, :provider

      def initialize(app:, llm:, provider:)
        @app = app
        @llm = llm
        @provider = provider
        #@context = context
      end

      def process(task)
        Raider::Tasks.const_get(task.to_s.classify).new(task_runner: self, app:, llm:, provider:)
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
      end

      def chat_message(prompt)
        messages = @provider.to_message_basic_to_json(prompt:)
        parse_response(llm_chat(messages: messages))
      end

      def chat_message_with_images(prompt:, images:)
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
    end
  end
end
