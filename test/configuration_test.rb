require 'test_helper'

class ConfigurationTest < MiniTest::Test
  def setup
    @config = StaticTracing::Configuration.instance
  end

  def test_mode
    assert_nil @config.mode
    @config.mode = 'tracing'
    assert_equal 'tracing', @config.mode
  end

  def test_signal
    assert_nil @config.signal
    @config.signal = 'tracing'
    assert_equal 'tracing', @config.signal
  end
end
