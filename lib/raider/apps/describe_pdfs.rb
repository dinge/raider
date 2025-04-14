# frozen_string_literal: true

module Raider
  module Apps
    class DescribePdfs < Base
      def process
        @pdf_util = Poros::PdfUtil.new(dpi: config[:dpi])
        process_files
      end

      private

      def process_files
        pdf_files.each { |pdf| process_file(pdf) }
      end

      def process_file(pdf)
        puts pdf
        img = @pdf_util.to_image(pdf)
        return unless img && File.exist?(img)

        response = create_task(:describe_image).process(img)
        dump(response)
        # cleanup(img)
      end

      def cleanup(path)
        FileUtils.rm_f(path)
      end
    end
  end
end
