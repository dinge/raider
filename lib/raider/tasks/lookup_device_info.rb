# frozen_string_literal: true

module Raider
  module Tasks
    class LookupDeviceInfo < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end

      def system_prompt
        <<~SYSTEM
          You are a chemical measurement device documentation and specification expert.
          Your role is to provide comprehensive, practical information about measurement devices
          that would be valuable for users analyzing their measurement data.

          Focus on providing:
          - Key technical specifications relevant to interpreting measurements
          - Common calibration requirements and procedures
          - Typical maintenance considerations
          - Known limitations or considerations for accurate measurements
          - Safety and handling guidelines
          - Troubleshooting common issues
          - Data interpretation guidelines specific to the device

          Provide information that helps users understand and trust their measurement results.
          Be concise but comprehensive, focusing on practical, actionable information.
        SYSTEM
      end

      def prompt
        device_context = if @inputs[:device_info].present?
                          "Device Information:\n#{JSON.pretty_generate(@inputs[:device_info])}"
                        else
                          "Device: #{@input}"
                        end

        <<~TEXT
          Based on the identified device, provide comprehensive information that would be helpful
          for a user analyzing measurements from this device.

          #{device_context}

          Please provide detailed information about:
          1. Key specifications and capabilities
          2. Calibration requirements and frequency
          3. Factors that can affect measurement accuracy
          4. Typical maintenance requirements
          5. Common issues and troubleshooting tips
          6. Best practices for obtaining accurate measurements
          7. Safety considerations if applicable
          8. How to interpret the measurement values
          9. Any relevant standards or compliance information

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          technical_specifications: {
            measurement_range: 'Operating range for each parameter',
            accuracy: 'Specified accuracy and precision',
            resolution: 'Display/measurement resolution',
            response_time: 'Time to stable reading',
            operating_conditions: 'Temperature, humidity, etc.'
          },
          calibration_info: {
            frequency: 'How often calibration is needed',
            procedure: 'Brief overview of calibration process',
            required_standards: 'Calibration buffers or standards needed',
            verification: 'How to verify calibration is valid'
          },
          accuracy_factors: [
            'Temperature effects on measurement',
            'Sample contamination considerations',
            'Electrode/sensor aging',
            'Buffer or standard storage'
          ],
          maintenance: {
            routine: 'Daily/weekly maintenance tasks',
            periodic: 'Monthly/yearly maintenance',
            consumables: 'Parts that need regular replacement',
            storage: 'Proper storage when not in use'
          },
          troubleshooting: [
            {
              issue: 'Unstable readings',
              possible_causes: ['Poor electrode condition', 'Sample temperature variation'],
              solutions: ['Clean/replace electrode', 'Allow temperature to stabilize']
            }
          ],
          best_practices: [
            'Allow sufficient equilibration time',
            'Use fresh calibration standards',
            'Rinse electrode between samples',
            'Record ambient temperature'
          ],
          safety_notes: [
            'Handle chemicals according to SDS',
            'Use appropriate PPE',
            'Dispose of waste properly'
          ],
          interpretation_guide: {
            normal_ranges: 'Typical values for common applications',
            data_quality_indicators: 'How to assess measurement quality',
            reporting: 'How to properly report results'
          },
          standards_compliance: [
            'ISO standards applicable',
            'Regulatory compliance (FDA, EPA, etc.)',
            'Industry-specific guidelines'
          ],
          helpful_resources: [
            'User manual reference',
            'Manufacturer support contact',
            'Relevant technical documentation'
          ]
        }
      end
    end
  end
end
