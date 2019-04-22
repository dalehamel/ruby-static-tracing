# frozen_string_literal: true

module StaticTracing
  # A wrapper for a USDT tracepoint provider
  # This corresponds to a namespace of tracepoints
  # By convention, we will often create one per
  # class or module.
  class Provider
    attr_accessor :name

    # Provider couldn't be found in collection
    class ProviderNotFound < StandardError; end

    class << self
      # Gets a provider by name
      # or creates one if not exists
      def register(namespace)
        providers[namespace] ||= new(namespace)
      end

      # Gets a provider instance by name
      def fetch(namespace)
        providers.fetch(namespace) do
          raise ProviderNotFound
        end
      end

      # Enables each provider, ensuring
      # it is loaded into memeory
      def enable!
        providers.values.each(&:enable)
      end

      # Forcefully disables all providers,
      # unloading them from memory
      def disable!
        providers.values.each(&:disable)
      end

      def clean
        # FIXME: this should free first
        @providers = {}
      end

      private

      # A global collection of providers
      def providers
        @providers ||= {}
      end
    end

    attr_reader :namespace, :tracepoints

    # Adds a new tracepoint to this provider
    # FIXME - should this be a dictionary, or are duplicate names allowed?
    def add_tracepoint(tracepoint, *args)
      if tracepoint.is_a?(String)
        tracepoint = Tracepoint.new(namespace, tracepoint, *args)
      elsif tracepoint.is_a?(Tracepoint)
        @tracepoints << tracepoint
      end
      tracepoint
    end

    # Enable the provider, loading it into memory
    def enable
      @enabled = _enable_provider
    end

    # Disables the provider, unloading it from memory
    def disable
      @enabled = !_disable_provider
    end

    # Returns true if the provider is enabled,
    # meaning it is loaded into memory
    def enabled?
      @enabled
    end

    # Only supported on systems (linux) where backed by file
    def path; end

    def destroy; end

    private

    # ALWAYS use register, never call .new dilectly
    def initialize(namespace)
      if StaticTracing::Platform.supported_platform?
        provider_initialize(namespace)
        @enabled = false
      else
        StaticTracing.issue_disabled_tracepoints_warning
      end
      @namespace = namespace
      @tracepoints = []
    end
  end
end
