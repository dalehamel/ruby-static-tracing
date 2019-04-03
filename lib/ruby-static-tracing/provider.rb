module StaticTracing
  class Provider #:nodoc:

    class << self
      def register(namespace)
        providers[namespace] = new(namespace)
      end

      private

      def providers
        @providers ||= {}
      end
    end

    def initialize(name)
      if StaticTracing.linux?
        provider_initialize(name)
      else
        StaticTracing.issue_disabled_tracepoints_warning
      end
      @name = name
    end

# FIXME - how to store list of tracepoints on provider? Allocate map in C?
#    def tracepoints
#      []
#    end
    def enable
    end

    def disable
    end

    # FIXME add binding to check if enabled
    def enabled?
    end

    def destroy
    end

    def initialize_provider(*)
    end
  end
end
