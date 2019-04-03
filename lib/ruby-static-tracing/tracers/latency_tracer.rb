# frozen_string_literal: true

module StaticTracing
  class Tracers
    class LatencyTracer
      LATENCY_TRACER_METHOD_PREFIX = 'latency_tracer_original_method_'

      class << self
        def register(method_name, provider: nil)
          klass = binding.receiver
          modified_classes[klass] << method_name
          provider ||= underscore(klass.name)

          klass.alias_method original_method_name(method_name), method_name
          klass.define_method(method_name) do
            start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
            result = send(old_method_name)
            duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - start_time
            LatencyTracer.fire_tracepoint(provider, method_name, duration)
            result
          end
        end

        # TODO: alias_method will add a copy of the method in memory so enabling and disabling
        # tracers will cause the memory of a program to continously grow.
        def disable!
          modified_classes.each do |klass, methods|
            methods.each do |method_name|
              klass.alias_method method_name, original_method_name(method_name)
            end
          end
        end

        def fire_tracepoint(provider, name, duration)
          return
          tracepoint(provider, name).fire(name, duration)
        end

        private

        def original_method_name(method_name)
          "#{LATENCY_TRACER_METHOD_PREFIX}#{method_name}"
        end

        def tracepoint(provider, name)
          @tracepoints[name] ||= StaticTracing::Tracepoint.new(provider, name, String, Interger)
        end

        def modified_classes
          @modified_classes ||= Hash.new { [] }
        end

        def underscore(class_name)
          class_name.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
        end
      end
    end
  end
end
