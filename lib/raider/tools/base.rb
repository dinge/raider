module Raider
  module Tools
    class Base
      def initialize(config)
        @config = config
      end

      def pdf_files
        Dir.glob(File.join(@config.directory, "*.pdf"))
      end

      # def create_llm_handler
      #   puts "using #{@config.provider.to_s.camelize}Handler"
      #   "Raider::Handlers::#{@config.provider.to_s.camelize}Handler".constantize.new
      # end

      def create_task(task, handler:)
        handler_instance = "Raider::Handlers::#{handler.to_s.camelize}Handler".constantize.new
        Raider::Tasks.const_get(task.to_s.classify).new(handler: handler_instance)
      end

      protected

      def output_debug(analysis)
        puts "\nDocument Analysis:"
        puts JSON.pretty_generate(analysis)
      end

      def log_response(file_path, response)
        FileUtils.mkdir_p('logs')
        handler_name = @config.provider.to_s
        log_file = "logs/describe_image-#{handler_name}.log"

        entry = {
          timestamp: Time.now.iso8601,
          file_path:,
          response: response
        }

        File.open(log_file, 'a') do |f|
          f.puts [entry].to_yaml
        end
      end
    end
  end
end
