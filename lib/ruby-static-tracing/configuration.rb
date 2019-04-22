# frozen_string_literal: true

module StaticTracing
  class Configuration
    # Modes of operation for tracers
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

    # A new configuration instance
    def initialize
      @mode = Modes::SIGNAL
      @signal = Modes::SIGNALS::SIGPROF
      enable_trap
    end

    # Sets the mode [ON, OFF, SIGNAL]
    # Default is SIGNAL
    def mode=(new_mode)
      handle_old_mode
      @mode = new_mode
      handle_new_mode
    end

    # Sets the SIGNAL to listen to,
    # Default is SIGPROF
    def signal=(new_signal)
      disable_trap
      @signal = new_signal
      enable_trap
    end

    # Adds a new tracer globally
    def add_tracer(tracer)
      Tracers.add(tracer)
    end

    private

    # Clean up trap handlers if mode changed to not need it
    def handle_old_mode
      disable_trap if @mode == Modes::SIGNAL
    end

    # Enable trap handlers if needed
    def handle_new_mode
      if @mode == Modes::SIGNAL
        enable_trap
      elsif @mode == Modes::ON
        StaticTracing.enable!
      elsif @mode == Modes::OFF
        StaticTracing.disable!
      end
    end

    # Disables trap handler
    def disable_trap
      Signal.trap(@signal, 'DEFAULT')
    end

    # Enables a new trap handler
    def enable_trap
      Signal.trap(@signal) { StaticTracing.toggle_tracing! }
    end
  end
end
