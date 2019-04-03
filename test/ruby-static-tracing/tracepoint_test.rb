# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  class TracepointTest < MiniTest::Test
    def setup
      @tracepoint = Tracepoint.new('test', 'my_method', Integer, String)
    end

    def test_fire_match_the_right_args
      assert_raises(Tracepoint::InvalidArgumentError) do
        @tracepoint.fire('hello', 1)
      end

      @tracepoint.fire(1, 'hello')
    end
  end
end
