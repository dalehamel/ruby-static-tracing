# frozen_string_literal: true

require 'ruby-static-tracing/tracers/latency_tracer'

module StaticTracing
  module Tracers
    module Concerns
      module LatencyTracer
        def self.included(base)
          methods = base.public_instance_methods(false)
          StaticTracing::Tracers::LatencyTracer.register(base, methods)
        end
      end
    end
  end
end
