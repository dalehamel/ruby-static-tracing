# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  class TracepointTest < MiniTest::Test
    def setup
      @tracepoint = Tracepoint.new('test', 'my_method', Integer, String)
    end

    def test_initialize_raises_when_args_is_not_supported
      assert_raises(Tracepoint::InvalidArgType) do
        Tracepoint.new('test', 'my_method', Integer, Float)
      end
    end

    def test_fire_match_the_right_args
      assert_raises(Tracepoint::InvalidArgumentError) do
        @tracepoint.fire('hello', 1)
      end

      @tracepoint.expects(:fire).once
      @tracepoint.fire(1, 'hello')
    end

    def test_tracepoint_implicitly_declare_provider
      p = StaticTracing::Provider.fetch(@tracepoint.provider_name)
      assert_equal(p.namespace, 'test')
    end

    def test_access_provider_through_tracepoint
      assert_equal(@tracepoint.provider.namespace, 'test')
    end
  end
end
