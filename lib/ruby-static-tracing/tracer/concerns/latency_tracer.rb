# frozen_string_literal: true

require 'ruby-static-tracing/tracer/latency'

module StaticTracing
  module Tracer
    module Concerns
      module Latency
        def self.included(base)
          methods = base.public_instance_methods(false)
          StaticTracing::Tracer::Latency.register(base, methods)
        end
      end
    end
  end
end
