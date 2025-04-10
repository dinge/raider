require 'test_helper'

class RaiderConfigTest < Minitest::Test
  def test_default_config_values
    config = Raider::Config.new

    assert_equal ".", config.directory
    assert_equal false, config.force
    assert_equal true, config.debug
    assert_equal :open_ai, config.provider
    assert_equal 200, config.dpi
  end
end
