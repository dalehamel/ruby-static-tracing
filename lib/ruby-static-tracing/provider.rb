# frozen_string_literal: true

module StaticTracing
  class Provider #:nodoc:
    attr_accessor :name
    class ProviderNotFound < StandardError; end

    class << self
      def register(namespace)
        providers[namespace] ||= new(namespace)
      end

      def fetch(namespace)
        providers.fetch(namespace) do
          raise ProviderNotFound
        end
      end

      def enable!
        providers.values.each(&:enable)
      end

      def disable!
        providers.values.each(&:disable)
      end

      def clean
        @providers = {}
      end

      private

      def providers
        @providers ||= {}
      end
    end

    attr_reader :namespace

    def initialize(namespace)
      if StaticTracing::Platform.supported_platform?
        provider_initialize(namespace)
      else
        StaticTracing.issue_disabled_tracepoints_warning
      end
      @namespace = namespace
    end

    def add_tracepoint(method_name, *args)
      Tracepoint.new(namespace, method_name, *args)
    end

    # FIXME: - how to store list of tracepoints on provider? Allocate map in C?
    #    def tracepoints
    #      []
    #    end
    def enable; end

    def disable; end

    # FIXME: add binding to check if enabled
    def enabled?; end

    def destroy; end

    def provider_initialize(*); end
  end
end
