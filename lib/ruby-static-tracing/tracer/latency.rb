# frozen_string_literal: true

module StaticTracing
  module Tracer
    class Latency < Base
      set_wrapping_function lambda { |*args, &block|
        start_time = StaticTracing.nsec
        result = super(*args, &block)
        duration = StaticTracing.nsec - start_time
        method_name = __method__.to_s
        provider = Tracer::Helpers.underscore(self.class.name)
        Tracepoints.get(provider, method_name).fire(method_name, duration)
        result
      }

      set_tracepoint_data_types(String, Integer)
    end
  end
end
