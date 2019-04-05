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
              puts "probing...."
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
          tracepoint(provider, name).fire(name, duration)
        end

        private

        def tracepoint(provider, name)
          tracepoints[provider][name] ||= begin
            t = StaticTracing::Tracepoint.new(provider, name.to_s, String, Integer)
            puts t.inspect
            p = StaticTracing::Provider.fetch(t.provider)
            puts p.inspect
            p.enable
            puts "enabled"
            puts p.enabled?
            t
          end
        end

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
