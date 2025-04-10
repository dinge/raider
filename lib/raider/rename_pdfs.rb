module Raider
  class RenamePdfs
    def initialize(config)
      @config = config
      @pdf_processor = Processors::PdfProcessor.new(dpi: config.dpi)
      @llm_handler = create_llm_handler
    end

    def run
      process_files
    end

    private

    def process_files
      pdf_files.shuffle[0, 3].each { |pdf| process_file(pdf) }
    end

    def process_file(pdf)
      puts pdf
      img = @pdf_processor.to_image(pdf)
      return unless img && File.exist?(img)

      analysis = @llm_handler.analyze_document(img)
      output_debug(analysis) if @config.debug

      new_name = @pdf_processor.generate_filename(analysis)
      @pdf_processor.rename(pdf, new_name, force: @config.force)
      @pdf_processor.cleanup(img)
    end

    def pdf_files
      Dir.glob(File.join(@config.directory, "*.pdf"))
    end

    def create_llm_handler
      puts "using #{@config.provider.to_s.camelize}Handler"
      "Raider::Handlers::#{@config.provider.to_s.camelize}Handler".constantize.new
    end

    def output_debug(analysis)
      puts "\nDocument Analysis:"
      puts JSON.pretty_generate(analysis)
    end
  end
end
