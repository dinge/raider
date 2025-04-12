module Raider
  module Apps
    class RenamePdfs < Base
      def initialize(config)
        super
        @pdf_backer = Backers::PdfBacker.new(dpi: config.dpi)
        @config = config
      end

      def run
        process_files
      end

      private

      def process_files = pdf_files.each { |pdf| process_file(pdf) }

      def process_file(pdf)
        puts pdf
        img = @pdf_backer.to_image(pdf)
        return unless img && File.exist?(img)

        analysis = create_task(:fetch_basic_letter_info, handler: @config.provider).process(img)

        log_response(pdf, analysis)
        output_debug(analysis) if @config.debug

        new_name = generate_filename(analysis)
        rename(pdf, new_name, force: @config.force)
        cleanup(img)
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
