# frozen_string_literal: true

require 'ruby-static-tracing/tracers/latency_tracer'

module StaticTracing
  module Tracers
    module Concerns
      module LatencyTracer
        def self.included(base)
          base.public_instance_methods(false).each do |method_name|           
            StaticTracing::Tracers::LatencyTracer.register(base, method_name)
          end
        end
      end
    end
  end
end
