# frozen_string_literal: true

require 'test_helper'
require 'ruby-static-tracing/tracers/concerns/latency_tracer'

module StaticTracing
  module Tracers
    module Concerns
      class LatencyTracerTest < MiniTest::Test
        class Example
          def noop
          end

          include StaticTracing::Tracers::Concerns::LatencyTracer

          def untraced_noop
          end
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

        def test_untraced_noop_will_not_fire_an_event
          StaticTracing::Tracepoint.any_instance.expects(:fire).never
          @example.untraced_noop
        end
      end
    end
  end
end
