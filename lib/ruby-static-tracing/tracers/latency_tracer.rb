# frozen_string_literal: true
require 'unmixer'

using Unmixer

module StaticTracing
  module Tracers
    class LatencyTracer
      class LatencyModuleGenerator < Module
        def initialize(provider)
          @provider = provider
        end

        def add_override(methods)
          methods.each do |method|
            probe = StaticTracing::Tracers::LatencyTracer.tracepoint(@provider, method)
            define_method(method) do |*args, &block|
              start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
              result = super(*args, &block)
              duration = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - start_time
              probe.fire(method.to_s, duration)
              result
            end
          end
        end
      end

      class << self
        def register(klass, method_names, provider: nil)
          provider ||= underscore(klass.name)
          latency_module = LatencyModuleGenerator.new(provider)
          modified_classes[klass] ||= latency_module
          modified_classes[klass].add_override(Array(method_names))
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
          tracepoint(provider, name).fire(name.to_s, duration)
        end

        def tracepoint(provider, name)
          tracepoints[provider][name] ||= begin
            StaticTracing::Tracepoint.new(provider, name.to_s, String, Integer)
          end
        end

        private

        def tracepoints
          @tracepoints ||= Hash.new { |hash, key| hash[key] = {} }
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
