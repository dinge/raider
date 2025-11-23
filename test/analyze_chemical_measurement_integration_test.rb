# frozen_string_literal: true

require 'test_helper'

module Raider
  module Apps
    class AnalyzeChemicalMeasurementIntegrationTest < Minitest::Test
      def setup
        @test_image = File.expand_path('data/chemical_device_ph_meter.ppm', __dir__)
        @metadata = {
          sample_id: 'TEST-2025-001',
          operator: 'Test User',
          location: 'Lab A',
          timestamp: '2025-01-15 14:30:00'
        }

        # Set a fake API key for testing (VCR will intercept requests)
        ENV['OPENAI_API_KEY'] = 'test_api_key'
      end

      def teardown
        ENV.delete('OPENAI_API_KEY')
      end

      def test_full_workflow_with_vcr
        # Skip if test image doesn't exist
        skip "Test image not found at #{@test_image}" unless File.exist?(@test_image)

        # Run the full analysis with VCR
        app = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
          input: @test_image,
          inputs: @metadata
        )

        # Verify app completed
        refute_nil app, 'App should return a result'
        refute_nil app.context, 'App should have context'

        # Verify outputs exist
        assert app.context.respond_to?(:outputs), 'Context should have outputs'
        outputs = app.context.outputs

        # Verify device information
        if outputs[:device]
          device = outputs[:device]
          assert device.key?(:device_name), 'Device should have device_name'
          assert device.key?(:manufacturer), 'Device should have manufacturer'
          assert device.key?(:model), 'Device should have model'

          # Verify specific values from VCR cassette
          assert_equal 'Mettler Toledo SevenCompact S220 pH Meter', device[:device_name]
          assert_equal 'Mettler Toledo', device[:manufacturer]
          assert_equal 'S220', device[:model]
        end

        # Verify measurements
        if outputs[:measurements]
          measurements = outputs[:measurements]
          assert measurements.is_a?(Array), 'Measurements should be an array'
          assert measurements.length > 0, 'Should have at least one measurement'

          # Find pH measurement
          ph_measurement = measurements.find { |m| m[:parameter] == 'pH' }
          if ph_measurement
            assert_equal 7.42, ph_measurement[:value]
            assert_equal 'pH', ph_measurement[:unit]
            assert_equal 'good', ph_measurement[:quality]
          end

          # Find temperature measurement
          temp_measurement = measurements.find { |m| m[:parameter] == 'Temperature' }
          if temp_measurement
            assert_equal 25.3, temp_measurement[:value]
            assert_equal '°C', temp_measurement[:unit]
          end
        end

        # Verify device details
        if outputs[:device_details]
          details = outputs[:device_details]
          assert details.key?(:technical_specifications), 'Should have technical specifications'
          assert details.key?(:calibration_info), 'Should have calibration info'
          assert details.key?(:maintenance), 'Should have maintenance info'
        end

        # Verify metadata was preserved
        if outputs[:metadata]
          assert_equal @metadata[:sample_id], outputs[:metadata][:sample_id]
          assert_equal @metadata[:operator], outputs[:metadata][:operator]
        end

        # Verify human-readable output
        if app.context.respond_to?(:output)
          output_text = app.context.output
          refute_nil output_text, 'Should have human-readable output'
          assert output_text.is_a?(String), 'Output should be a string'
          assert output_text.length > 100, 'Output should be substantial'

          # Verify key information is in the output
          assert_match(/pH.*7\.42/i, output_text) if output_text.include?('7.42')
          assert_match(/Mettler Toledo/i, output_text) if output_text.include?('Mettler')
        end
      end

      def test_workflow_with_minimal_inputs
        skip "Test image not found at #{@test_image}" unless File.exist?(@test_image)

        # Test with minimal inputs (just the image)
        app = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
          input: @test_image,
          inputs: {}
        )

        refute_nil app, 'App should return a result even with no metadata'
        assert app.context.respond_to?(:outputs), 'Context should have outputs'
      end

      def test_vcr_cassettes_exist
        cassette_dir = File.expand_path('vcr_cassettes/analyze_chemical_measurement/0/test-001', __dir__)

        # Verify VCR cassettes exist
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
    end
  end
end
