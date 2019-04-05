# frozen_string_literal: true
require 'unmixer'

require 'ruby-static-tracing/tracers/helpers'

using Unmixer

module StaticTracing
  module Tracers
    class StackTracer
      class WrappedMethods < Module
        def initialize(provider, methods)
          methods.each do |method|
            define_method(method) do |*args, &block|
              current_stack = self.send(:caller).join("\n")

              StackTracer.fire_tracepoint(provider, method.to_s, current_stack )
              super(*args, &block)
            end
          end
        end
      end

      class << self
        include Tracers::Helpers

        def register(klass, method_names, provider: nil)
          provider ||= underscore(klass.name)
          method_overrides = WrappedMethods.new(provider, Array(method_names))

          modified_classes[klass] = method_overrides
        end

        def enable!
          modified_classes.each do |klass, wrapped_methods|
            klass.prepend(wrapped_methods)
          end
        end

        def disable!
          modified_classes.each do |klass, wrapped_methods|
            klass.instance_eval { unprepend(wrapped_methods) }
          end
        end

        def fire_tracepoint(provider, name, current_stack)
          tracepoint(provider, name).fire(name, current_stack)
        end

        private

        def tracepoint(provider, name)
          tracepoints[name] ||= StaticTracing::Tracepoint.new(provider, name, String, String)
        end

        def modified_classes
          @modified_classes ||= {}
        end

        def tracepoints
          @tracepoints ||= {}
        end
      end
    end
  end
end
