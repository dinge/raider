# frozen_string_literal: true

require 'test_helper'

module Raider
  module Apps
    class AnalyzeChemicalMeasurementTest < Minitest::Test
      def setup
        @test_image = 'test/fixtures/chemical_device.jpg'
        @metadata = {
          sample_id: 'TEST-2025-001',
          operator: 'Test User',
          location: 'Lab A',
          timestamp: '2025-01-15 14:30:00'
        }
      end

      def test_app_class_exists
        assert defined?(Raider::Apps::AnalyzeChemicalMeasurement),
               'AnalyzeChemicalMeasurement app class should be defined'
      end

      def test_app_has_analyze_method
        assert Raider::Apps::AnalyzeChemicalMeasurement.respond_to?(:analyze),
               'App should have .analyze class method'
      end

      def test_task_classes_exist
        assert defined?(Raider::Tasks::OcrAndExtractMeasurements),
               'OcrAndExtractMeasurements task should exist'
        assert defined?(Raider::Tasks::IdentifyDevice),
               'IdentifyDevice task should exist'
        assert defined?(Raider::Tasks::LookupDeviceInfo),
               'LookupDeviceInfo task should exist'
        assert defined?(Raider::Tasks::FormatHumanResponse),
               'FormatHumanResponse task should exist'
      end

      def test_tasks_inherit_from_base
        assert Raider::Tasks::OcrAndExtractMeasurements.ancestors.include?(Raider::Tasks::Base),
               'OcrAndExtractMeasurements should inherit from Base'
        assert Raider::Tasks::IdentifyDevice.ancestors.include?(Raider::Tasks::Base),
               'IdentifyDevice should inherit from Base'
        assert Raider::Tasks::LookupDeviceInfo.ancestors.include?(Raider::Tasks::Base),
               'LookupDeviceInfo should inherit from Base'
        assert Raider::Tasks::FormatHumanResponse.ancestors.include?(Raider::Tasks::Base),
               'FormatHumanResponse should inherit from Base'
      end

      def test_tasks_have_required_methods
        task_class = Raider::Tasks::OcrAndExtractMeasurements

        assert task_class.instance_methods.include?(:process),
               'Task should have process method'
        assert task_class.instance_methods.include?(:system_prompt),
               'Task should have system_prompt method'
        assert task_class.instance_methods.include?(:prompt),
               'Task should have prompt method'
        assert task_class.instance_methods.include?(:example_response_struct),
               'Task should have example_response_struct method'
      end

      def test_ocr_task_response_structure
        task_class = Raider::Tasks::OcrAndExtractMeasurements
        # Create a minimal instance to check structure
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:ocr_text), 'Response should include ocr_text'
        assert struct.key?(:measurements), 'Response should include measurements array'
        assert struct.key?(:device_text), 'Response should include device_text'
        assert struct[:measurements].is_a?(Array), 'Measurements should be an array'
      end

      def test_identify_device_task_response_structure
        task_class = Raider::Tasks::IdentifyDevice
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:device_name), 'Response should include device_name'
        assert struct.key?(:manufacturer), 'Response should include manufacturer'
        assert struct.key?(:model), 'Response should include model'
        assert struct.key?(:device_type), 'Response should include device_type'
        assert struct.key?(:confidence_level), 'Response should include confidence_level'
      end

      def test_lookup_device_info_response_structure
        task_class = Raider::Tasks::LookupDeviceInfo
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:technical_specifications), 'Response should include technical_specifications'
        assert struct.key?(:calibration_info), 'Response should include calibration_info'
        assert struct.key?(:maintenance), 'Response should include maintenance'
        assert struct.key?(:best_practices), 'Response should include best_practices'
      end

      def test_format_human_response_structure
        task_class = Raider::Tasks::FormatHumanResponse
        struct = task_class.allocate.example_response_struct

        assert struct.key?(:text), 'Response should include text field'
        assert struct.key?(:summary_sections), 'Response should include summary_sections'
        assert struct.key?(:key_findings), 'Response should include key_findings'
      end

      # Integration test (requires mocking or actual API)
      # def test_full_workflow_with_mock
      #   # This would require mocking the LLM responses
      #   # Skipped for now as it requires proper VCR setup
      # end
    end
  end
end
