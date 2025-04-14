require 'test_helper'

module Raider
  module Apps
    class RenamePdfsTest < Minitest::Test
      include TestHelpers

      def setup
        stub_llm_analysis
        @config = {
          directory: 'test/fixtures',
          force: false,
          debug: true,
          provider: :open_ai,
          dpi: 200
        }
        @renamer = RenamePdfs.new(@config)
      end

      def test_processes_pdf_file
        # Create a temporary PDF for testing
        pdf_path = 'test/fixtures/test.pdf'
        FileUtils.mkdir_p('test/fixtures')
        FileUtils.touch(pdf_path)

        # Mock the PDF processing methods
        Backers::PdfBacker.any_instance.stubs(:to_image).returns('test.png')

        # Test the renaming process
        @renamer.process

        # Clean up
        FileUtils.rm_rf('test/fixtures')
      end
    end
  end
end
