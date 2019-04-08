# frozen_string_literal: true
require 'ruby-static-tracing/tracers/base'

module StaticTracing
  module Tracers
    class LatencyTracer < Base
      set_wrapping_function -> (*args, &block) {
        start_time = StaticTracing.nsec
        result = super(*args, &block)
        duration = StaticTracing.nsec - start_time
        method_name = __method__.to_s
        provider = Tracers::Helpers.underscore(self.class.name)
        Tracepoints.get(provider, method_name).fire(method_name, duration)
        result
      }

      set_tracepoint_data_types(String, Integer)
    end
  end
end
