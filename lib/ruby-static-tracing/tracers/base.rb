require 'unmixer'
using Unmixer

module StaticTracing
  module Tracers
    class Base
      class << self
        include Tracers::Helpers

        def register(klass, *method_names, provider: nil)
          @provider ||= underscore(klass.name)

          method_overrides = function_wrapper.new(provider, @wrapping_function)

          modified_classes[klass] = method_overrides
          modified_classes[klass].add_override(Array(method_names))
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

        def fire_tracepoint(name, *args)
          tracepoint(@provider, name).fire(name, *args)
        end

        private

        def function_wrapper
          Class.new(Module) do
            attr_reader :provider

            def initialize(provider, wrapping_function)
              @provider = provider
              @wrapping_function = wrapping_function
            end

            def add_override(methods)
              methods.each do |method|
                define_method(method, @wrapping_function)
              end
            end
          end
        end

        def tracepoint(provider, name)
          tracepoints[name] ||=
            StaticTracing::Tracepoint.new(
              provider, name, *tracepoint_data_types
            )
        end

        def modified_classes
          @modified_classes ||= {}
        end

        def tracepoints
          @tracepoints ||= {}
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
