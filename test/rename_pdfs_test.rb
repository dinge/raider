require 'test_helper'

module Raider
  class RenamePdfsTest < Minitest::Test
    include TestHelpers

    def setup
      stub_llm_analysis
      @config = Config.new
      @config.instance_variable_set(:@directory, "test/fixtures")
      @renamer = RenamePdfs.new(@config)
    end

    def test_processes_pdf_file
      # Create a temporary PDF for testing
      pdf_path = "test/fixtures/test.pdf"
      FileUtils.mkdir_p("test/fixtures")
      FileUtils.touch(pdf_path)

      # Mock the PDF processing methods
      PdfProcessor.any_instance.stubs(:to_image).returns("test.png")
      PdfProcessor.any_instance.stubs(:cleanup)
      PdfProcessor.any_instance.stubs(:rename)
      
      # Test the renaming process
      @renamer.run

      # Clean up
      FileUtils.rm_rf("test/fixtures")
    end
  end
end