# frozen_string_literal: true

module StaticTracing
  module Platform
    module_function

    def linux?
      /linux/.match(RUBY_PLATFORM)
    end

    def darwin?
      /darwin/.match(RUBY_PLATFORM)
    end

    def supported_platform?
      linux? || darwin?
    end
  end
end
