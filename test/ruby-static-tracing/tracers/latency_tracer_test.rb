# frozen_string_literal: true

require 'ruby-static-tracing/tracers/latency_tracer'

module StaticTracing
  class Tracers
    class LatencyTracerTest < MiniTest::Test
      class Example
        def noop
        end
        LatencyTracer.register(self, :noop)
      end

      def setup
        @example = Example.new
        LatencyTracer.enable!
      end

      def test_noop_will_fire_an_event_when
        Process.expects(:clock_gettime).twice.with(Process::CLOCK_MONOTONIC, :nanosecond).returns(1)
        @example.noop
      end

      def test_disable_will_prevent_firing_an_event
        Process.expects(:clock_gettime).never
        LatencyTracer.disable!
        @example.noop
      end
    end
  end
end
