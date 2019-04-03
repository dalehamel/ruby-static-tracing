require 'singleton'

module StaticTracing
  class Configuration
    include Singleton
    attr_accessor :mode, :signal
  end
end
