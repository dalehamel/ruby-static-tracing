module StaticTracing
  class Provider #:nodoc:

    class << StaticTracing::Provider
      # Ensure that there can only be one provider for each name
      def instance(*args)
        StaticTracing.providers[args.first] ||= new(*args) # FIXME allocate this dictionary of providers
      end
    end

    def initialize(name)
      if StaticTracing.linux?
        initialize_provider(name)
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
  end
end
