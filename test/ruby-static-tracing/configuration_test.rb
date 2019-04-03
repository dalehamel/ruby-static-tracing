# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  class ConfigurationTest < MiniTest::Test
    def setup
      @config = Configuration.instance
    end

    def test_mode
      @config.mode = 'tracing'
      assert_equal 'tracing', @config.mode
    end

    def test_signal
      @config.signal = 'INT'
      assert_equal 'INT', @config.signal
    end

    def test_changing_the_mode_to_off_will_force_static_tracing_to_be_disabled
      StaticTracing.enable!
      assert StaticTracing.enabled?
      @config.mode = Configuration::Modes::OFF
      refute StaticTracing.enabled?
    end

    def test_changing_the_mode_to_on_will_force_static_tracing_to_be_enabled
      StaticTracing.disable!
      refute StaticTracing.enabled?
      @config.mode = Configuration::Modes::ON
      assert StaticTracing.enabled?
    end

    def test_changing_the_signal_will_disable_trapping_the_original_signal
      Signal.expects(:trap).with(@config.signal, 'DEFAULT')
      Signal.expects(:trap).with('INT')
      @config.signal = 'INT'
    end
  end
end
