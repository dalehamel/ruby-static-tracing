# frozen_string_literal: true

module StaticTracing
  class Tracers
    class << self
      def add(tracer)
        tracers << tracer
      end

      def enable!
        tracers.each(&:enable!)
      end

      def disable!
        tracers.each(&:disable!)
      end

      private

      def tracers
        @tracers ||= []
      end
    end
  end
end
