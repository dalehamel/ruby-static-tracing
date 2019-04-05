# frozen_string_literal: true

module StaticTracing
  class Tracepoints
    class << self
      def add_tracepoint(provider, name, data_types)
        tracepoints[provider][name.to_s] ||= begin
          StaticTracing::Tracepoint.new(provider, name.to_s, *data_types)
        end
      end

      def get(provider, name)
        tracepoints.fetch(provider).fetch(name)
      end

      private

      def tracepoints
        @tracepoints ||= Hash.new { |hash, key| hash[key] = {} }
      end
    end
  end
end
