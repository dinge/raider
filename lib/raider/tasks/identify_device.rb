# frozen_string_literal: true

module Raider
  module Tasks
    class IdentifyDevice < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)

        # For device identification, we want to analyze both the image and OCR data
        if @input.is_a?(String) && File.exist?(@input)
          chat_message_with_images(prompt, [@input])
        else
          chat(prompt)
        end
      end

      def system_prompt
        <<~SYSTEM
          You are a chemical measurement device identification expert with comprehensive knowledge of:
          - Laboratory and industrial measurement instruments
          - Chemical analysis equipment manufacturers (Mettler Toledo, Thermo Fisher, Hach, etc.)
          - pH meters, spectrophotometers, titrators, chromatographs, and other analytical devices
          - Device model numbers, series, and specifications
          - Common features and capabilities of measurement instruments

          Your task is to accurately identify the specific device from visual characteristics,
          display layout, OCR text, and any visible branding or model information.

          Always provide the most specific identification possible (brand, model, series)
          and include confidence level in your assessment.
        SYSTEM
      end

      def prompt
        ocr_context = if @inputs[:ocr_data].present?
                        "OCR Data from device:\n#{JSON.pretty_generate(@inputs[:ocr_data])}"
                      else
                        ""
                      end

        <<~TEXT
          Identify this chemical measurement device based on the image and extracted data.

          #{ocr_context}

          Please provide:
          - Device brand/manufacturer
          - Specific model name and number
          - Device type/category (pH meter, spectrophotometer, etc.)
          - Key features and capabilities
          - Typical measurement range and accuracy
          - Your confidence level in this identification

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          device_name: 'Full device name (brand + model)',
          manufacturer: 'Manufacturer name',
          model: 'Specific model number',
          series: 'Product series if applicable',
          device_type: 'Category of device (pH meter, spectrophotometer, etc.)',
          measurement_types: ['pH', 'Temperature', 'mV'],
          key_features: [
            'Auto-calibration',
            'Multi-parameter measurement',
            'Data logging'
          ],
          typical_range: {
            pH: '0.00 - 14.00',
            temperature: '-5 to 105 °C'
          },
          typical_accuracy: {
            pH: '±0.01 pH',
            temperature: '±0.1 °C'
          },
          confidence_level: 'high/medium/low',
          identification_basis: 'What information led to this identification',
          alternative_models: ['Other possible models if confidence is not high']
        }
      end
    end
  end
end
