# frozen_string_literal: true

# Example usage of the AnalyzeChemicalMeasurement app

require 'raider'

# Basic usage with just an image path
image_path = '/path/to/chemical_device_image.jpg'

app = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
  input: image_path,
  inputs: {}
)

# Access the results
puts "Output: #{app.output}"
puts "Structured outputs: #{app.outputs.to_json}"

# ============================================================================
# Usage with metadata
# ============================================================================

app_with_metadata = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
  input: image_path,
  inputs: {
    sample_id: 'SAMPLE-2025-001',
    operator: 'John Doe',
    location: 'Lab A',
    timestamp: '2025-01-15 14:30:00',
    notes: 'Weekly quality control check'
  }
)

# ============================================================================
# Accessing specific outputs
# ============================================================================

# Get device information
device = app_with_metadata.outputs[:device]
puts "Device: #{device[:device_name]}"
puts "Manufacturer: #{device[:manufacturer]}"
puts "Model: #{device[:model]}"

# Get measurements
measurements = app_with_metadata.outputs[:measurements]
measurements.each do |measurement|
  puts "#{measurement[:parameter]}: #{measurement[:value]} #{measurement[:unit]}"
end

# Get device details
device_details = app_with_metadata.outputs[:device_details]
puts "Calibration info: #{device_details[:calibration_info]}"

# Get human-readable output
puts "\n=== Human-Readable Summary ===\n"
puts app_with_metadata.output

# ============================================================================
# Example with Rails ActiveRecord integration
# ============================================================================

# When used in Rails with Raider::App model for persistence:
# The app will automatically create a persisted record with all context

# Example in a Rails controller:
# class MeasurementsController < ApplicationController
#   def analyze
#     app = Raider::Apps::AnalyzeChemicalMeasurement.analyze(
#       input: params[:image].path,
#       inputs: {
#         sample_id: params[:sample_id],
#         operator: current_user.name
#       }
#     )
#
#     # The app.persisted_app will contain the ActiveRecord instance
#     measurement_record = app.persisted_app
#
#     render json: {
#       id: measurement_record.id,
#       output: app.output,
#       outputs: app.outputs
#     }
#   end
# end

# ============================================================================
# Expected output structure
# ============================================================================

# The app returns:
# {
#   output: "Human-readable summary text...",
#   outputs: {
#     device: {
#       device_name: "Mettler Toledo SevenCompact S220",
#       manufacturer: "Mettler Toledo",
#       model: "S220",
#       device_type: "pH meter",
#       # ... more device info
#     },
#     measurements: [
#       {
#         parameter: "pH",
#         value: 7.42,
#         unit: "pH",
#         quality: "good",
#         timestamp: "2025-01-15 14:30:00"
#       },
#       # ... more measurements
#     ],
#     device_details: {
#       technical_specifications: { ... },
#       calibration_info: { ... },
#       accuracy_factors: [ ... ],
#       # ... more details
#     },
#     metadata: {
#       sample_id: "SAMPLE-2025-001",
#       operator: "John Doe",
#       # ... user-provided metadata
#     }
#   }
# }
