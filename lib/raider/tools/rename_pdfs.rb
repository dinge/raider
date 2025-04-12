module Raider
  module Tools
    class RenamePdfs < Base
      def initialize(config)
        super
        @pdf_processor = Processors::PdfProcessor.new(dpi: config.dpi)
        @llm_handler = create_llm_handler
        @config = config
      end

      def run
        process_files
      end

      private

      def process_files
        pdf_files.each { |pdf| process_file(pdf) }
      end

      def process_file(pdf)
        puts pdf
        img = @pdf_processor.to_image(pdf)
        return unless img && File.exist?(img)

        # analysis = @llm_handler.analyze_document(img)
        analysis = create_task(:describe_image, handler: @config.provider).process(img)

        log_response(pdf, analysis)
        output_debug(analysis) if @config.debug

        new_name = generate_filename(analysis)
        rename(pdf, new_name, force: @config.force)
        cleanup(img)
      end

      def create_llm_handler
        puts "using #{@config.provider.to_s.camelize}Handler"
        "Raider::Handlers::#{@config.provider.to_s.camelize}Handler".constantize.new
      end

      def generate_filename(analysis)
        date = analysis["main_date"].to_s
        date_prefix = Date.parse(date).strftime("%Y%m%d-") rescue ""

        sender = analysis["sender_name"].to_s.parameterize[0..30]
        category = analysis["category"].to_s.parameterize

        "#{date_prefix}#{sender}-#{category}.pdf"
      end

      def rename(old_path, new_name, force: false)
        new_path = File.join(File.dirname(old_path), new_name)
        message = if force
          FileUtils.mv(old_path, new_path)
          "Renamed to"
        else
          "Suggestion"
        end
        puts "#{message}: #{File.basename(old_path)} -> #{new_name}"
      end

      def cleanup(path)
        File.delete(path) if File.exist?(path)
      end
    end
  end
end
