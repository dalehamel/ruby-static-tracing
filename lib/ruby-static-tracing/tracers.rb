# frozen_string_literal: true

module StaticTracing
  # Tracers are a layer of abstraction above tracepoints. They are opinionated
  # and contextual ways of applying tracepoints to an application.
  class Tracers
    # Error for an invalid tracer
    class InvalidTracerError < StandardError
      def initialize
        msg = <<~MSG
          You need to add a valid tracer.

          To create a valid tracer please inherit from StaticTracing::Tracer::Base
          and follow the guide on how to create tracers
        MSG
        super(msg)
      end
    end

    class << self
      def add(tracer)
        raise InvalidTracerError unless tracer < StaticTracing::Tracer::Base

        tracers << tracer
      end

      def enable!
        tracers.each(&:enable!)
      end

      def disable!
        tracers.each(&:disable!)
      end

      def clean
        @tracers = []
      end

      private

      def tracers
        @tracers ||= []
      end
    end
  end
end
