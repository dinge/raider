# frozen_string_literal: true

module Raider
  module Runners
    class TaskRunner
      attr_reader :app, :llm, :provider
      attr_reader :agent
      attr_reader :system_prompt, :current_task, :current_context, :messages
      attr_reader :llm_response, :raw_response, :response_message, :parsed_response

      alias context current_context

      def initialize(app:, llm:, provider:, agent: nil)
        @app = app
        @llm = llm
        @provider = provider
        @agent = agent

        @current_task_class = nil
        @current_task = nil
        @system_prompt = 'You are a helpful agent.'
        @messages = []
        @tool_calls = []
        @tool_call_results = []
      end

      def process(task)
        @current_task_class = Raider::Tasks.const_get(task.to_s.camelize)
        if @current_task_class.const_defined?(@llm.llm_ident.to_s.camelize)
          @current_task_class = @current_task_class.const_get(@llm.llm_ident.to_s.camelize)
        end
        @current_task = @current_task_class.new(task_runner: self, app:, llm:, provider:, agent:)
        @current_context = @current_task.context
        @current_task
      end

      def llm_chat(**args)
        if (tools = @current_task.tools) && @messages.size == 2
          args.merge!(tools:, tool_choice: 'required')
        end

        puts "-----------------------------------------------------------"
        puts args
        puts "-----------------------------------------------------------"


        ruby_llm_client.chat(**args)
      end

      def ruby_llm_client
        @provider.ruby_llm_client_class.new(**build_current_ruby_llm_client_options)
      end

      def ruby_llm_base_client # like OpenAI::Client.new
        ruby_llm_client.client
      end

      def build_current_ruby_llm_client_options
        @provider.provider_options
                 .deep_merge(@provider.llm_options_by_ident(@llm))
                 .deep_merge(@llm.llm_options)
                 .deep_merge(@current_task.llm_options)
      end

      def set_system_prompt(system_prompt)
        @system_prompt = system_prompt
      end

      def chat(prompt, system_prompt: nil)
        prompt_struct = prompt
        prompt = "```json\n#{JSON.pretty_generate(prompt)}\n```" if prompt.is_a?(Hash)
        # prompt = prompt.to_s
        @provider.system_prompt = system_prompt || @system_prompt
        @messages.push(*(messages = @provider.to_messages_basic_to_json(prompt:)))
        @current_context.input = prompt_struct
        regular_response = process_llm_response(llm_chat(messages: messages))

        if @current_task.tools && @messages.size == 4
          prepare_tool_response
        else
          regular_response
        end
      end

      def chat_message_with_images(prompt, images, system_prompt: nil)
        @provider.system_prompt = system_prompt || @system_prompt
        images = images.map { base64_encode(it) }
        @messages.push(*(messages = @provider.to_messages_basic_with_images_to_json(prompt:, images:)))
        process_llm_response(llm_chat(messages: messages))
      end

      def prepare_tool_response
        # process_llm_response(llm_chat(messages: @messages)) # .to_yaml
        @current_context.output =
          @tool_call_results.group_by do |hash|
            hash[:name]
          end.transform_values do |arr|
            arr.map { |h| h[:content] }
          end
      end

      def process_llm_response(llm_response)
        @llm_response = llm_response
        @raw_response = @llm_response.raw_response

        if @current_task.tools && (@tool_calls = @provider.parse_tool_calls(@raw_response).presence)
          process_tool_chain
        else
          process_regular_response
        end
      end

      def process_tool_chain
        log_response(@raw_response, {})
        @messages.push(@raw_response.dig('choices', 0, 'message'))
        @tool_call_results = process_tool_calls
        @messages.push(*@tool_call_results)
      end

      def process_tool_calls
        @tool_calls.map do
          { tool_call_id: it['id'],
            role: 'tool',
            name: it['function']['name'] ,
            content: call_tool_method(it['function']['name'], it['function']['arguments']) }
        end
      end

      def call_tool_method(tool_method, tool_args_json)
        @current_task.send("#{tool_method}_tool", **JSON.parse(tool_args_json, symbolize_names: true))
      end

      def process_regular_response
        @response_message = @provider.parse_raw_response(@raw_response)
        parse_json_safely(@response_message).tap do |hash_response|
          @parsed_response = hash_response
          @current_context.output = hash_response
          log_response(@raw_response, hash_response)
        end
      end

      def parse_json_safely(str)
        json_match = str.match(/\{.*\}/m)
        json_match ? JSON.parse(json_match[0]) : { llm_message: str }
      rescue JSON::ParserError => e
        { error_message: e.message,
          llm_message: str }
      end

      def log_response(raw_response, hash_response)
        FileUtils.mkdir_p('log/raider')

        entry = {
          timestamp: Time.now.iso8601,
          app_context: @app.app_context,
          raw_response:,
          hash_response:
        }

        puts JSON.pretty_generate(entry) if @app.app_context[:debug]

        log_file = "log/raider/#{@app.app_ident}--#{@current_task.ident}--#{@provider.provider_ident}--#{@llm.llm_ident}.log"
        File.open(log_file, 'a') do |f|
          f.puts [entry].to_yaml
        end
      end

      def base64_encode(image) = Base64.strict_encode64(File.binread(image))
    end
  end
end
