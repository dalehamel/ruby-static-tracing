# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  class TracepointsTest < MiniTest::Test
    def setup
      Tracepoints.add('test', 'my_method', [Integer, String])
    end

    def teardown
      Tracepoints.clean
    end

    def test_get_returns_tracepoint
      tracepoint = Tracepoints.get('test', 'my_method')
      assert_instance_of Tracepoint, tracepoint
    end

    def test_raises_error_if_provider_does_not_exists
      assert_raises(StaticTracing::Tracepoints::ProviderMissingError) do
        Tracepoints.get('noop', 'my_method')
      end
    end

    def test_raises_error_if_tracepoint_does_not_exists
      assert_raises(StaticTracing::Tracepoints::TracepointMissingError) do
        Tracepoints.get('test', 'noop')
      end
    end
  end
end
