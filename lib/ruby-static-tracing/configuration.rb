# frozen_string_literal: true

require 'singleton'

module StaticTracing
  class Configuration
    module Modes
      ON = 'ON'
      OFF = 'OFF'
      SIGNAL = 'SIGNAL'

      module SIGNALS
        SIGPROF = 'PROF'
      end
    end

    class << self
      def instance
        @instance ||= new
      end
    end

    attr_reader :mode, :signal

    def initialize
      @mode = Modes::SIGNAL
      @signal = Modes::SIGNALS::SIGPROF
      enable_trap
    end

    def mode=(new_mode)
      handle_old_mode
      @mode = new_mode
      handle_new_mode
    end

    def signal=(new_signal)
      disable_trap
      @signal = new_signal
      enable_trap
    end

    private

    def handle_old_mode
      disable_trap if @mode == Modes::SIGNAL
    end

    def handle_new_mode
      if @mode == Modes::SIGNAL
        enable_trap
      elsif @mode == Modes::ON
        StaticTracing.enable!
      elsif @mode == Modes::OFF
        StaticTracing.disable!
      end
    end

    def disable_trap
      Signal.trap(@signal, 'DEFAULT')
    end

    def enable_trap
      Signal.trap(@signal) { StaticTracing.toggle_tracing! }
    end
  end
end
