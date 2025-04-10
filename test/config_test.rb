require 'test_helper'

module Raider
  class ConfigTest < Minitest::Test
    def test_default_config_values
      config = Config.new
      
      assert_equal ".", config.directory
      assert_equal false, config.force
      assert_equal true, config.debug
      assert_equal :open_ai, config.provider
      assert_equal 200, config.dpi
    end

    def test_config_from_args
      args = ["test/path", "--force", "--provider", "llama3"]
      config = Config.from_args(args)

      assert_equal "test/path", config.directory
      assert_equal true, config.force
      assert_equal :llama3, config.provider
    end

    def test_validates_directory
      assert_raises(SystemExit) do
        # Capture stderr to avoid noise in test output
        capture_io do
          Config.from_args(["nonexistent/directory"])
        end
      end
    end

    private

    def capture_io
      orig_stdout = $stdout
      orig_stderr = $stderr
      captured_stdout = StringIO.new
      captured_stderr = StringIO.new
      $stdout = captured_stdout
      $stderr = captured_stderr

      yield

      return captured_stdout.string, captured_stderr.string
    ensure
      $stdout = orig_stdout
      $stderr = orig_stderr
    end
  end
end