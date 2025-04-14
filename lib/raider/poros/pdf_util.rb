# frozen_string_literal: true

module Raider
  module Poros
    class PdfUtil
      def initialize(dpi: 200)
        @dpi = dpi
      end

      def to_image(pdf)
        output = "#{pdf.sub(/\.pdf$/i, '')}-1.png"
        cmd = "pdftoppm -f 1 -l 1 -r #{@dpi} -png -scale-to 1200 \"#{pdf}\" \"#{pdf.sub(/\.pdf$/i, '')}\""

        system(cmd)
        output
      end
    end
  end
end
