# frozen_string_literal: true

module StaticTracing
  module Tracer
    # A stack tracer gets the stack trace at point when
    # the tracer is executed
    class Stack < Base
      set_wrapping_function lambda { |*args, &block|
        current_stack = send(:caller).join("\n")
        method_name = __method__.to_s
        provider = Tracer::Helpers.underscore(self.class.name)
        Tracepoints.get(provider, method_name).fire(method_name, current_stack)
        super(*args, &block)
      }

      set_tracepoint_data_types(String, String)
    end
  end
end
