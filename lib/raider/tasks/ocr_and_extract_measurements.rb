# frozen_string_literal: true

module Raider
  module Tasks
    class OcrAndExtractMeasurements < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat_message_with_images(prompt, [input])
      end

      def system_prompt
        <<~SYSTEM
          You are a specialized chemical measurement device analysis expert with the following capabilities:
          - Precise OCR extraction from measurement device displays
          - Deep understanding of chemical measurement instruments and their readouts
          - Expertise in identifying measurement units, values, and device parameters
          - Accurate extraction of numerical values with proper unit handling
          - Recognition of device status indicators, warnings, and calibration data

          Focus areas:
          1. Accurate text extraction from device displays (LCD, LED, digital readouts)
          2. Precise measurement value extraction with units
          3. Identification of measurement types (pH, temperature, concentration, etc.)
          4. Recognition of device status and error codes
          5. Extraction of sample IDs, batch numbers, and timestamps if present

          Always respond in valid JSON format with structured measurement data.
        SYSTEM
      end

      def prompt
        context = if @inputs.present?
                    "Additional context: #{@inputs.to_json}"
                  else
                    ""
                  end

        <<~TEXT
          Analyze this chemical measurement device image and extract all visible information.

          #{context}

          Please perform OCR on the device display and extract:
          - All measurement values with their units
          - Device model/type information visible in the image
          - Sample identifiers or batch numbers
          - Timestamps or dates
          - Any warning messages or status indicators
          - Calibration information if visible
          - Any other relevant text or data

          Be thorough and precise with numerical values and units.

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          ocr_text: 'Complete OCR text from the device display',
          measurements: [
            {
              parameter: 'pH',
              value: 7.42,
              unit: 'pH',
              quality: 'good',
              timestamp: '2025-01-15 14:30:00'
            },
            {
              parameter: 'Temperature',
              value: 25.3,
              unit: '°C',
              quality: 'good',
              timestamp: '2025-01-15 14:30:00'
            }
          ],
          device_text: 'Any visible device model or brand text',
          sample_id: 'Sample identifier if present',
          batch_number: 'Batch number if present',
          status_indicators: ['READY', 'CALIBRATED'],
          warnings: [],
          calibration_date: 'Last calibration date if visible',
          additional_info: 'Any other relevant information from the display'
        }
      end
    end
  end
end
