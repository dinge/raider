# frozen_string_literal: true

module Raider
  module Apps
    class AnalyzeChemicalMeasurement < Base
      def self.analyze(input:, inputs: {}, with_app_persistence: false, with_auto_context: false)
        new(
          with_app_persistence:,
          with_auto_context:,
          with_vcr: true,
          input:,
          inputs:,
          on_task_create: :show_task_start,
          llm: :gpt5_mini
        ).tap do |app|
          app.agents.analyze_measurement(input:) do |ag|
            # Step 1: OCR and extract all measurements from the device image
            ocr_data = ag.tasks.ocr_and_extract_measurements(input:, inputs:)

            # Step 2: Identify the device from the image and extracted data
            device_info = ag.tasks.identify_device(
              input:,
              inputs: { ocr_data: }
            )

            # Step 3: Look up additional device information that could be helpful
            device_details = ag.tasks.lookup_device_info(
              input: device_info[:device_name],
              inputs: { device_info: }
            )

            # Step 4: Format a human-readable response
            human_response = ag.tasks.format_human_response(
              input:,
              inputs: {
                ocr_data:,
                device_info:,
                device_details:,
                metadata: inputs
              }
            )

            # Add structured outputs
            ag.add_to_output!(
              outputs: {
                device: device_info,
                measurements: ocr_data[:measurements],
                device_details:,
                metadata: inputs
              }
            )

            # Add human-readable output
            ag.add_to_output!(output: human_response[:text])
          end
        end
      end

      def show_task_start(task)
        Raider.log(task_started: task.ident)
      end
    end
  end
end
