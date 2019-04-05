# frozen_string_literal: true
require 'ruby-static-tracing/tracers/base'

module StaticTracing
  module Tracers
    class LatencyTracer < Base
      set_wrapping_function -> (*args, &block) {
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
        result = super(*args, &block)
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - start_time
        LatencyTracer.fire_tracepoint(__method__, duration)
        result
      }

      set_tracepoint_data_types(String, Integer)
    end
  end
end
