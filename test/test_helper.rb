require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'
require 'simplecov'
require 'fileutils'

# Start SimpleCov
SimpleCov.start

# Pretty test output
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

# Add lib to load path and load our app
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'raider'

# Mock responses
MOCK_LLM_RESPONSE = {
  "main_date" => "2024-03-20",
  "sender_name" => "Test Company",
  "category" => "invoice"
}.freeze

module TestHelpers
  # Helper to stub LLM responses
  def stub_llm_analysis
    # Mock the LLM handler creation
    mock_handler = mock('llm_handler')
    mock_handler.stubs(:analyze_document).returns(MOCK_LLM_RESPONSE)
    Raider::RenamePdfs.any_instance.stubs(:create_llm_handler).returns(mock_handler)
  end
end