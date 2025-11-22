# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'
require 'simplecov'
require 'fileutils'
require 'vcr'
require 'webmock/minitest'

# Start SimpleCov
SimpleCov.start

# Pretty test output
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

# Add lib to load path and load our app
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'raider'

# Configure VCR
VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }
  config.allow_http_connections_when_no_cassette = false
end

# Mock responses
MOCK_LLM_RESPONSE = {
  'sender_date' => '2024-03-20',
  'sender_name' => 'Test Company',
  'category' => 'invoice'
}.freeze

module TestHelpers
  # Helper to stub LLM responses
  def stub_llm_analysis
    # Mock the handler and task
    mock_handler = mock('llm_handler')
    mock_task = mock('task')

    # Setup the task mock
    mock_task.stubs(:process).returns(MOCK_LLM_RESPONSE)

    # Setup handler class mock
    mock_handler_class = mock('handler_class')
    mock_handler_class.stubs(:new).returns(mock_handler)

    # Stub the constantize call that creates the handler
    String.any_instance.stubs(:constantize).returns(mock_handler_class)

    # Stub task creation
    Raider::Tasks.stubs(:const_get).returns(Class.new do
      def initialize(handler:)
        @handler = handler
      end

      def process(*)
        MOCK_LLM_RESPONSE
      end
    end)
  end
end
