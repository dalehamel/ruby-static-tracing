# frozen_string_literal: true

module StaticTracing
  # FIXME: - why do we need this class? We should store tracepoints
  # on providers, and get the list of all tracepoints from the list of providers
  class Tracepoints
    class ProviderMissingError < StandardError; end
    class TracepointMissingError < StandardError; end

    class << self
      def add(provider, name, data_types)
        tracepoints[provider][name.to_s] ||= begin
          StaticTracing::Tracepoint.new(provider, name.to_s, *data_types)
        end
      end

      def get(provider, name)
        tracepoints
          .fetch(provider) { raise_error(ProviderMissingError) }
          .fetch(name) { raise_error(TracepointMissingError) }
      end

      def clean
        @tracepoints ||= Hash.new { |hash, key| hash[key] = {} }
      end

      private

      def tracepoints
        @tracepoints ||= Hash.new { |hash, key| hash[key] = {} }
      end

      def raise_error(error)
        raise error
      end
    end
  end
end
