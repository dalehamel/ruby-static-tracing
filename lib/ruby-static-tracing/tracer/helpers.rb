# frozen_string_literal: true

module StaticTracing
  module Tracer
    module Helpers
      module_function

      def underscore(class_name)
        class_name.gsub(/::/, '_')
                  .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                  .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                  .tr('-', '_')
                  .downcase
      end
    end
  end
end
