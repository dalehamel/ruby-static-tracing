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
        # FIXME: benchmark this, we may need to cache the provider instance on the object
        # This lookup is a bit of a hack
        t = Provider.fetch(provider).tracepoints[method_name]
        t.fire(method_name, duration) if t
        result
      }

      set_tracepoint_data_types(String, Integer)
    end
  end
end
