# frozen_string_literal: true

module StaticTracing
  # Platform detection for ruby-static-tracing
  module Platform
    module_function

    # Returns true if platform is linux
    def linux?
      /linux/.match(RUBY_PLATFORM)
    end

    # Returns true if platform is darwin
    def darwin?
      /darwin/.match(RUBY_PLATFORM)
    end

    # Returns true if platform is known to be supported
    def supported_platform?
      linux? || darwin?
    end
  end
end
