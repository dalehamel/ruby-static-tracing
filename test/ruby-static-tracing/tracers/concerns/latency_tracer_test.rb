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
        end
  
        def test_noop_will_fire_an_event_when
          Process.expects(:clock_gettime).twice.with(Process::CLOCK_MONOTONIC, :nanosecond).returns(1)
          @example.noop
        end
  
        def test_untraced_noop_will_not_fire_an_event
          Process.expects(:clock_gettime).never
          @example.untraced_noop
        end
      end
    end
  end
end
