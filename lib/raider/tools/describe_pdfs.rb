module Raider
  module Tools
    class DescribePdfs < Base
      def initialize(config)
        super
        @pdf_processor = Processors::PdfProcessor.new(dpi: config.dpi)
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

        analysis = create_task(:describe_image, handler: @config.provider).process(img)

        log_response(pdf, analysis)
        output_debug(analysis) if @config.debug

        # cleanup(img)
      end

      def cleanup(path)
        File.delete(path) if File.exist?(path)
      end
    end
  end
end
