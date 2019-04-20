# frozen_string_literal: true

require 'unmixer'
using Unmixer

require 'ruby-static-tracing/tracer/helpers'

module StaticTracing
  module Tracer
    class Base
      class << self
        include Tracer::Helpers

        def register(klass, *method_names, provider: nil)
          provider ||= underscore(klass.name)
          method_overrides = function_wrapper.new(provider, @wrapping_function, @data_types)
          modified_classes[klass] ||= method_overrides
          modified_classes[klass].add_override(method_names.flatten)
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

        private

        def function_wrapper
          Class.new(Module) do
            def initialize(provider, wrapping_function, data_types)
              @provider = provider
              @wrapping_function = wrapping_function
              @data_types = data_types
            end

            def add_override(methods)
              methods.each do |method|
                Tracepoints.add(@provider, method, @data_types)
                define_method(method.to_s, @wrapping_function)
              end
            end
          end
        end

        def modified_classes
          @modified_classes ||= {}
        end

        def set_tracepoint_data_types(*args)
          @data_types = *args
        end

        def tracepoint_data_types
          @data_types
        end

        def set_wrapping_function(callable)
          @wrapping_function = callable
        end
      end
    end
  end
end
