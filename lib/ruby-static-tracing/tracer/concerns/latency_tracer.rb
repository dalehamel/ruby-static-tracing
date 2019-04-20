# frozen_string_literal: true

module StaticTracing
  module Tracer
    module Concerns
      # Including this module will cause the target
      # to have latency tracers added around every method
      module Latency
        def self.included(base)
          methods = base.public_instance_methods(false)
          StaticTracing::Tracer::Latency.register(base, methods)
        end
      end
    end
  end
end
