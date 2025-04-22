# frozen_string_literal: true

module Raider
  module Apps
    class RenamePdfs < Base
      VALID_RECEIVERS = %w[firma-pflaum megorei produktgenuss unknown]

      def process
        @pdf_util = Poros::PdfUtil.new(dpi: @config[:dpi])
        @output_directory = @config[:output_directory]
        process_files
      end

      private

      def process_files
        pdf_files.each { |pdf| process_file(pdf) }
      end

      def process_file(input_path)
        puts input_path
        img = @pdf_util.to_image(input_path)
        return unless img && File.exist?(img)

        response = create_task(:fetch_basic_letter_info).process(img, VALID_RECEIVERS)
        dump(response)

        value_corrector_response = create_task(:value_corrector).process(response['receiver_name'], VALID_RECEIVERS)
        dump(value_corrector_response)
        valid_receiver_name = value_corrector_response.fetch('response', 'unknown')

        new_name = generate_filename(response)

        output_directory = File.join(@output_directory, valid_receiver_name)
        rename_file(input_path, output_directory, new_name, force: @config[:force])
        cleanup(img)
      end

      def perform_tasks
        task.vision.business_letter.basic_info(image, app.base.valid_receivers).then do
          task.correctors.value_corrector(it.receiver_name, app.base.valid_receivers)
        end
      end

      def generate_filename(response)
        date = response['sender_date'].to_s
        date_prefix = begin
          Date.parse(date).strftime('%Y%m%d-')
        rescue StandardError
          Time.now.year.to_s
        end

        sender = response['sender_name'].to_s.parameterize[0..30]
        category = response['category'].to_s.parameterize

        "#{date_prefix}#{sender}-#{category}.pdf"
      end

      def rename_file(input_path, output_directory, new_name, force: false)
        FileUtils.mkdir_p(output_directory)
        new_path = File.join(output_directory, new_name)
        new_path.gsub!('.pdf', "#{Time.now.to_f}.pdf") if File.exist?(new_path)
        message = if force
                    FileUtils.cp(input_path, new_path)
                    'Renamed to'
                  else
                    'Suggestion'
                  end
        puts "#{message}: #{File.basename(input_path)} -> #{new_path}"
      end

      def cleanup(path)
        FileUtils.rm_f(path)
      end
    end
  end
end
