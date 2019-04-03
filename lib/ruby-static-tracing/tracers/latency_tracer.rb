# frozen_string_literal: true

module StaticTracing
  module Tracers
    class LatencyTracer
      LATENCY_TRACER_ORIGINAL_METHOD_PREFIX = 'latency_tracer_original_method_'
      LATENCY_TRACER_TRACED_METHOD_PREFIX = 'latency_tracer_traced_method_'

      class << self
        def register(klass, method_name, provider: nil)
          modified_classes[klass] ||= []
          modified_classes[klass] << method_name
          provider ||= underscore(klass.name)
          original_method_name = build_original_method_name(method_name)
          traced_method_name = build_traced_method_name(method_name)

          klass.define_method(traced_method_name) do |*args|
            start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
            result = send(original_method_name, *args)
            duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - start_time
            LatencyTracer.fire_tracepoint(provider, method_name, duration)
            result
          end

          # This will create a copy of the original method under `latency_tracer_original_method_*`
          # and then overwrite the method with the instrumented method`latency_tracer_traced_method_*`
          klass.alias_method original_method_name, method_name
          klass.alias_method method_name, traced_method_name
        end

        # TODO: alias_method will add a copy of the method in memory so enabling and disabling
        # tracers will cause the memory of a program to continously grow.
        def enable!
          modified_classes.each do |klass, methods|
            methods.each do |method_name|
              klass.alias_method method_name, build_traced_method_name(method_name)
            end
          end
        end

        # TODO: alias_method will add a copy of the method in memory so enabling and disabling
        # tracers will cause the memory of a program to continously grow.
        def disable!
          modified_classes.each do |klass, methods|
            methods.each do |method_name|
              klass.alias_method method_name, build_original_method_name(method_name)
            end
          end
        end

        def fire_tracepoint(provider, name, duration)
          return
          tracepoint(provider, name).fire(name, duration)
        end

        private

        def build_traced_method_name(method_name)
          "#{LATENCY_TRACER_TRACED_METHOD_PREFIX}#{method_name}"
        end

        def build_original_method_name(method_name)
          "#{LATENCY_TRACER_ORIGINAL_METHOD_PREFIX}#{method_name}"
        end

        def tracepoint(provider, name)
          @tracepoints[name] ||= StaticTracing::Tracepoint.new(provider, name, String, Interger)
        end

        def modified_classes
          @modified_classes ||= {}
        end

        def underscore(class_name)
          class_name.gsub(/::/, '_').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
        end
      end
    end
  end
end
