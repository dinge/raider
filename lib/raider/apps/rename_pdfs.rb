module Raider
  module Apps
    class RenamePdfs < Base
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

        response = create_task(:fetch_basic_letter_info).process(img)
        dump(response)

        new_name = generate_filename(response)
        rename(pdf, new_name, force: @config[:force])
        cleanup(img)
      end

      def generate_filename(response)
        date = response['main_date'].to_s
        date_prefix = begin
          Date.parse(date).strftime('%Y%m%d-')
        rescue StandardError
          ''
        end

        sender = response['sender_name'].to_s.parameterize[0..30]
        category = response['category'].to_s.parameterize

        "#{date_prefix}#{sender}-#{category}.pdf"
      end

      def rename(old_path, new_name, force: false)
        new_path = File.join(File.dirname(old_path), new_name)
        message = if force
                    FileUtils.mv(old_path, new_path)
                    'Renamed to'
                  else
                    'Suggestion'
                  end
        puts "#{message}: #{File.basename(old_path)} -> #{new_name}"
      end

      def cleanup(path)
        File.delete(path) if File.exist?(path)
      end
    end
  end
end
