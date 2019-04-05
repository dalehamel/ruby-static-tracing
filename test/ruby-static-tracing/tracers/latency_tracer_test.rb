# frozen_string_literal: true

require 'test_helper'
require 'ruby-static-tracing/tracers/latency_tracer'

module StaticTracing
  module Tracers
    class LatencyTracerTest < MiniTest::Test
      class Example
        def noop
        end
        Tracers::LatencyTracer.register(self, :noop)

        def noop_with_args(*args, arg1:)
          Array(args).map { |arg| arg1 + arg }
        end
        Tracers::LatencyTracer.register(self, :noop_with_args)
      end

      def setup
        @example = Example.new
        Tracers::LatencyTracer.enable!
      end

      def teardown
        Tracers::LatencyTracer.disable!
      end

      def test_noop_will_fire_an_event_when
        StaticTracing::Tracepoint.any_instance.expects(:fire).once
        @example.noop
      end

      def test_disable_will_prevent_firing_an_event
        Tracers::LatencyTracer.disable!
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
        Tracers::LatencyTracer.disable!
        result = @example.noop_with_args(2, 3, arg1: 1)

        assert_equal([3, 4], result)
      end
    end
  end
end
