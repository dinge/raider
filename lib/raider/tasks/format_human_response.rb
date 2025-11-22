# frozen_string_literal: true

module Raider
  module Tasks
    class FormatHumanResponse < Base
      def process(input:, inputs: {})
        @input = input
        @inputs = inputs.compact_blank

        set_system_prompt(system_prompt)
        chat(prompt)
      end

      def system_prompt
        <<~SYSTEM
          You are a technical writing expert specializing in analytical chemistry and measurement reporting.
          Your role is to create clear, comprehensive, human-readable summaries of measurement data
          that combine technical accuracy with accessibility.

          Your summaries should:
          - Be well-structured and easy to read
          - Highlight the most important information first
          - Provide context and interpretation where helpful
          - Use appropriate technical terminology while remaining accessible
          - Include relevant warnings or notes about data quality
          - Suggest actionable next steps when appropriate

          Write in a professional but friendly tone, as if explaining results to a colleague.
        SYSTEM
      end

      def prompt
        context_summary = []

        if @inputs[:ocr_data].present?
          context_summary << "Measurement Data:\n#{JSON.pretty_generate(@inputs[:ocr_data])}"
        end

        if @inputs[:device_info].present?
          context_summary << "Device Information:\n#{JSON.pretty_generate(@inputs[:device_info])}"
        end

        if @inputs[:device_details].present?
          context_summary << "Device Details:\n#{JSON.pretty_generate(@inputs[:device_details])}"
        end

        if @inputs[:metadata].present?
          context_summary << "Additional Metadata:\n#{JSON.pretty_generate(@inputs[:metadata])}"
        end

        <<~TEXT
          Create a comprehensive, human-readable summary of the chemical measurement analysis.

          #{context_summary.join("\n\n")}

          Please generate a well-structured summary that includes:

          1. **Executive Summary**: Brief overview of what was measured and the key findings

          2. **Device Information**: What device was used and its key characteristics

          3. **Measurement Results**: Detailed presentation of all measured parameters with:
             - Parameter name and value with units
             - Assessment of data quality (if available)
             - Any warnings or notes

          4. **Device Context**: Important information about the device that helps interpret the results

          5. **Quality Considerations**: Factors that might affect measurement accuracy

          6. **Recommendations**: Any suggested actions based on the measurements or device status

          7. **Additional Notes**: Any other relevant information from the metadata or analysis

          Format the response as clear, professional text with appropriate headings and structure.
          Be thorough but concise, focusing on information that is actually present in the data.

          #{json_instruct}
        TEXT
      end

      def example_response_struct
        {
          text: 'Complete formatted human-readable summary with all sections',
          summary_sections: {
            executive_summary: 'Brief overview of key findings',
            device_info: 'Device identification and key specs',
            measurement_results: 'Formatted measurement data',
            device_context: 'Important device information',
            quality_considerations: 'Factors affecting accuracy',
            recommendations: 'Suggested actions',
            additional_notes: 'Other relevant information'
          },
          key_findings: [
            'pH: 7.42 (neutral, good quality)',
            'Temperature: 25.3°C (within normal range)'
          ],
          alerts: [
            'Device calibration due in 7 days'
          ],
          confidence: 'Overall confidence in the analysis (high/medium/low)'
        }
      end
    end
  end
end
