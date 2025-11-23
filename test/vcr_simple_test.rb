# frozen_string_literal: true

require 'test_helper'

class VcrSimpleTest < Minitest::Test
  def setup
    @test_image = File.expand_path('data/chemical_device_ph_meter.ppm', __dir__)
    ENV['OPENAI_API_KEY'] = 'test_api_key'
  end

  def teardown
    ENV.delete('OPENAI_API_KEY')
  end

  def test_vcr_cassettes_exist
    cassette_dir = File.expand_path('vcr_cassettes/analyze_chemical_measurement/0/test-001', __dir__)

    expected_cassettes = [
      'ocr_and_extract_measurements--0--gpt5_mini--.yml',
      'identify_device--0--gpt5_mini--.yml',
      'lookup_device_info--0--gpt5_mini--.yml',
      'format_human_response--0--gpt5_mini--.yml'
    ]

    expected_cassettes.each do |cassette|
      cassette_path = File.join(cassette_dir, cassette)
      assert File.exist?(cassette_path), "VCR cassette should exist: #{cassette}"
    end
  end

  def test_test_image_exists
    assert File.exist?(@test_image), "Test image should exist at #{@test_image}"
  end

  def test_vcr_configuration
    assert VCR.configuration.cassette_library_dir.end_with?('test/vcr_cassettes'),
           "Cassette dir should end with test/vcr_cassettes, got: #{VCR.configuration.cassette_library_dir}"
    refute_nil VCR.configuration, "VCR should be configured"
  end
end
