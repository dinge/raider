require 'date'
require 'fileutils'
require 'active_support/core_ext/string'

module Raider
  class PdfProcessor
    def initialize(dpi: 200)
      @dpi = dpi
    end

    def to_image(pdf)
      output = "#{pdf.sub(/\.pdf$/i, '')}-1.png"
      cmd = "pdftoppm -f 1 -l 1 -r #{@dpi} -png -scale-to 1200 \"#{pdf}\" \"#{pdf.sub(/\.pdf$/i, '')}\""

      system(cmd)
      output
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