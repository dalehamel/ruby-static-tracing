# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  module Tracer
    class LatencyTest < MiniTest::Test
      class Example
        def noop; end
        Tracer::Latency.register(self, :noop)

        def noop_with_args(*args, arg1:)
          Array(args).map { |arg| arg1 + arg }
        end
        Tracer::Latency.register(self, :noop_with_args)
      end

      def setup
        @example = Example.new
        Tracer::Latency.enable!
      end

      def teardown
        Tracer::Latency.disable!
      end

      def test_noop_will_fire_an_event_when
        StaticTracing::Tracepoint.any_instance.expects(:fire).once
        @example.noop
      end

      def test_disable_will_prevent_firing_an_event
        Tracer::Latency.disable!
        StaticTracing::Tracepoint.any_instance.expects(:fire).never
        @example.noop
      end

      def test_noop_with_args_will_fire_events
        StaticTracing::Tracepoint.any_instance.expects(:fire).once
        result = @example.noop_with_args(2, 3, arg1: 1)
        assert_equal([3, 4], result)
      end

      def test_noop_with_args_works_correctly_when_disabled
        StaticTracing::Tracepoint.any_instance.expects(:fire).never
        Tracer::Latency.disable!
        result = @example.noop_with_args(2, 3, arg1: 1)

        assert_equal([3, 4], result)
      end
    end
  end
end
