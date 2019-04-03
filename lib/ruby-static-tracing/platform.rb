# frozen_string_literal: true

module StaticTracing
  module Platform
    extend self

    def linux?
      /linux/.match(RUBY_PLATFORM)
    end
  end
end
