# frozen_string_literal: true

require 'test_helper'
require 'ruby-static-tracing/tracer/concerns/latency_tracer'

module StaticTracing
  module Tracer
    module Concerns
      class LatencyTest < MiniTest::Test
        class Example
          def noop; end

          include StaticTracing::Tracer::Concerns::Latency

          def untraced_noop; end
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

        def test_untraced_noop_will_not_fire_an_event
          StaticTracing::Tracepoint.any_instance.expects(:fire).never
          @example.untraced_noop
        end
      end
    end
  end
end
