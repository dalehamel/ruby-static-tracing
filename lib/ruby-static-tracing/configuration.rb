# frozen_string_literal: true

require 'singleton'

module StaticTracing
  class Configuration
    include Singleton
    attr_accessor :mode, :signal

    module Modes
      ON = 'ON'
      OFF = 'OFF'
      SIGNAL = 'SIGNAL'

      module SIGNALS
        SIGPROF = 'PROF'
      end
    end
  end
end
