# frozen_string_literal: true

require 'ruby-static-tracing/tracers/base'

module StaticTracing
  module Tracers
    class StackTracer < Base
      set_wrapping_function -> (*args, &block) {
        current_stack = self.send(:caller).join("\n")
        method_name = __method__.to_s
        provider = Tracers::Helpers.underscore(self.class.name)
        Tracepoints.get(provider, method_name).fire(method_name, current_stack)
        super(*args, &block)
      }

      set_tracepoint_data_types(String, String)
    end
  end
end
