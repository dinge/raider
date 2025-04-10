require 'test_helper'

class RaiderRenamePdfsTest < Minitest::Test
  include TestHelpers

  def setup
    stub_llm_analysis
    @config = Raider::Config.new
    @config.instance_variable_set(:@directory, "test/fixtures")
    @renamer = Raider::RenamePdfs.new(@config)
  end
end
