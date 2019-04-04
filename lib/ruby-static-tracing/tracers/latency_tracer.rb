# frozen_string_literal: true
require 'unmixer'

using Unmixer

module StaticTracing
  module Tracers
    class LatencyTracer
      class LatencyModuleGenerator < Module
        def initialize(provider, methods)
          methods.each do |method|
            define_method(method) do |*args, &block|
              start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
              result = super(*args, &block)
              duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - start_time
              LatencyTracer.fire_tracepoint(provider, method, duration)
              result
            end
          end
        end
      end

      class << self
        def register(klass, method_names, provider: nil)
          provider ||= underscore(klass.name)
          latency_module = LatencyModuleGenerator.new(provider, Array(method_names))
          modified_classes[klass] = latency_module
        end

        def enable!
          modified_classes.each do |klass, latency_module|
            klass.prepend latency_module
          end
        end

        def disable!
          modified_classes.each do |klass, latency_module|
            klass.instance_eval { unprepend latency_module }
          end
        end

        def fire_tracepoint(provider, name, duration)
          return
          tracepoint(provider, name).fire(name, duration)
        end

        def reset_modified_classes
          @modified_classes = {}
        end

        private

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
