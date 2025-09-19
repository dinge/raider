# frozen_string_literal: true

module Raider
  module Runners
    class TaskRunner
      attr_reader :app, :llm, :provider
      attr_reader :agent
      attr_reader :system_prompt, :current_task, :current_context, :messages
      attr_reader :llm_response, :raw_response, :response_message, :parsed_response, :processed_llm_response

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
        @llm_usages = []
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

      def llm_chat(**llm_args)
        if @current_task.with_tools? && @messages.size == 2
          llm_args.merge!(tools: @current_task.tools, tool_choice: 'required')
        end

        write_log(llm_args)
        ruby_llm_client.chat(**llm_args)
      end

      def ruby_llm_client
        @provider.ruby_llm_client_class.new(**build_current_ruby_llm_client_options)
      end

      def chat_with_responses(input, system_prompt: nil)
        input = input[:input]
        @provider.system_prompt = system_prompt || @system_prompt
        response = ruby_llm_base_client
          .responses.create(
            parameters: {
              model: 'gpt-5-mini',
              input:,
              instructions: system_prompt,
              # tools:,
              # tool_choice: "auto",
              # include: ["output[*].web_search_call.message"],
              # include: ["output[*].file_search_call.search_results"],
              # max_output_tokens: 4096,
              # max_tokens: 4096,
              # response_format: 'json',
            }
          )
        res = response.dig('output', 1, 'content', 0, 'text')
        @current_context.output = { response: res }
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

      def set_system_prompt(system_prompt) = @system_prompt = system_prompt

      def chat(prompt, system_prompt: nil)
        process_request(prompt, system_prompt:) { llm_chat(**it) }
      end

      def process_request(prompt, system_prompt:)
        prompt = "```json\n#{JSON.pretty_generate(prompt)}\n```" if prompt.is_a?(Hash)
        @current_context.input = prompt
        @provider.system_prompt = system_prompt || @system_prompt

        messages = @provider.to_messages_basic_to_json(prompt:)
        add_to_messages(messages)
        chat_response = yield(messages: messages)

        @processed_llm_response = process_llm_response(chat_response)
        @current_context.messages = @messages
        @current_context.llm_usage = @provider.parse_usage(@raw_response).presence
        @current_context.output = build_task_response
      end

      def add_to_messages(messages)
        @messages.push(*messages)
        messages
      end

      def build_task_response
        if @current_task.with_tools? && @messages.size >= 4
          @current_context.tool_calls = @tool_call_results.map { it.slice(:name, :tool_args) }
          build_tool_response
        else
          @processed_llm_response
        end
      end

      def chat_message_with_images(prompt, images, system_prompt: nil)
        @provider.system_prompt = system_prompt || @system_prompt
        images = images.map { base64_encode(it) }
        messages = @provider.to_messages_basic_with_images_to_json(prompt:, images:)
        add_to_messages(messages)
        process_llm_response(llm_chat(messages: messages))
      end

      def build_tool_response
        @tool_call_results.group_by do |hash|
          hash[:name]
        end.transform_values do |arr|
          arr.map { |h| h[:content] }
        end
      end

      def process_llm_response(llm_response)
        @llm_response = llm_response
        @raw_response = @llm_response.raw_response
        add_to_messages(@raw_response.dig('choices', 0, 'message'))

        if @current_task.with_tools? && (@tool_calls = @provider.parse_tool_calls(@raw_response).presence)
          process_tool_chain
        else
          process_regular_response
        end
      end

      def process_tool_chain
        write_log(@raw_response, {})
        @tool_call_results = @tool_calls.map(&method(:process_tool_call))
        add_to_messages(@tool_call_results)
      end

      def process_tool_call(tool_call)
        tool_method = tool_call.dig('function', 'name')
        tool_args = JSON.parse(tool_call.dig('function', 'arguments'), symbolize_names: true)
        {
          tool_call_id: tool_call.dig('id'),
          role: 'tool',
          name: tool_method ,
          content: call_tool_method(tool_method, tool_args),
          tool_args:
        }
      end

      def call_tool_method(tool_method, tool_args)
        @current_task.send("#{tool_method}_tool", **tool_args)
      end

      def process_regular_response
        @response_message = @provider.parse_raw_response(@raw_response)
        parse_json_safely(@response_message).tap do |hash_response|
          @parsed_response = hash_response
          write_log(@raw_response, hash_response)
        end
      end

      def parse_json_safely(str)
        json_match = str.match(/\{.*\}/m)
        json_match ? JSON.parse(json_match[0]) : { llm_message: str }
      rescue JSON::ParserError => e
        { error_message: e.message,
          llm_message: str }
      end

      def write_log(data, hash_response = {})
        FileUtils.mkdir_p('log/raider')

        entry = {
          timestamp: Time.now.iso8601,
          data:,
          # app_context: @app.app_context,
          # hash_response:
        }

        puts JSON.pretty_generate(entry) if @app.app_context[:debug]

        log_file = 'log/raider/raider.log'
        # log_file = "log/raider/#{@app.app_ident}--#{@current_task.ident}--#{@provider.provider_ident}--#{@llm.llm_ident}.log"
        File.open(log_file, 'a') { it.puts [entry].to_yaml }
      end

      def base64_encode(image) = Base64.strict_encode64(File.binread(image))
    end
  end
end
