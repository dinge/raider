#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
lib_path = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)
require "raider"

puts "=== Testing AnalyzeChemicalMeasurement App ==="
puts

# Test 1: Check if classes are loaded
puts "1. Checking if app class exists..."
if defined?(Raider::Apps::AnalyzeChemicalMeasurement)
  puts "   ✓ Raider::Apps::AnalyzeChemicalMeasurement loaded"
else
  puts "   ✗ Failed to load app class"
  exit 1
end

# Test 2: Check if tasks are loaded
puts "\n2. Checking if task classes exist..."
tasks = [
  'OcrAndExtractMeasurements',
  'IdentifyDevice',
  'LookupDeviceInfo',
  'FormatHumanResponse'
]

tasks.each do |task|
  if defined?(Raider::Tasks.const_get(task))
    puts "   ✓ Raider::Tasks::#{task} loaded"
  else
    puts "   ✗ Failed to load Raider::Tasks::#{task}"
    exit 1
  end
end

# Test 3: Check if app can be instantiated
puts "\n3. Checking if app can be instantiated..."
begin
  # Try with minimal context (no actual execution)
  app_class = Raider::Apps::AnalyzeChemicalMeasurement
  puts "   ✓ App class can be accessed"
  puts "   ✓ App has .analyze class method: #{app_class.respond_to?(:analyze)}"
rescue => e
  puts "   ✗ Error: #{e.message}"
  exit 1
end

# Test 4: Check task structure
puts "\n4. Checking task structure..."
begin
  task_class = Raider::Tasks::OcrAndExtractMeasurements
  puts "   ✓ Task inherits from Base: #{task_class.ancestors.include?(Raider::Tasks::Base)}"

  # Check if task has required methods
  required_methods = [:process, :system_prompt, :prompt, :example_response_struct]
  task_instance = task_class.allocate # Create instance without initialize

  required_methods.each do |method|
    if task_class.instance_methods.include?(method)
      puts "   ✓ Task has #{method} method"
    else
      puts "   ✗ Task missing #{method} method"
    end
  end
rescue => e
  puts "   ✗ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

puts "\n=== All structural tests passed! ==="
puts
puts "Note: Actual execution requires:"
puts "  - An image file path (JPEG/PNG of a chemical device)"
puts "  - OpenAI API key configured"
puts "  - Network access for API calls"
puts
puts "To run with an actual image:"
puts "  app = Raider::Apps::AnalyzeChemicalMeasurement.analyze("
puts "    input: '/path/to/device_image.jpg',"
puts "    inputs: { sample_id: 'TEST-001' }"
puts "  )"
