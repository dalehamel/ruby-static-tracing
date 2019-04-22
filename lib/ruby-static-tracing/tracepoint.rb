# frozen_string_literal: true

module StaticTracing
  class Tracepoint
    class InvalidArgumentError < StandardError
      def initialize(argument, expected_type)
        error_message = <<~ERROR_MESSAGE

          We expected the fire arguments to match with the ones specified on the creation of the Tracepoint

          You passed #{argument} => #{argument.class} and we expected the argument to be type #{expected_type}
        ERROR_MESSAGE
        super(error_message)
      end
    end
    class InvalidArgType < StandardError; end

    VALID_ARGS_TYPES = [Integer, String].freeze

    attr_reader :provider_name, :name, :args

    # Creates a new tracepoint.
    # If a provider by the name specified doesn't exist already,
    # one will be added implicitly.
    def initialize(provider_name, name, *args)
      @provider_name = provider_name
      @name = name
      validate_args(args)
      @args = args

      if StaticTracing::Platform.supported_platform?
        tracepoint_initialize(provider_name, name, args)
        provider.add_tracepoint(self)
      else
        StaticTracing.issue_disabled_tracepoints_warning
      end
    end

    # Fire a tracepoint, sending the data off to be received by
    # a tracing program like dtrace
    def fire(*values)
      values.each_with_index do |arg, i|
        raise InvalidArgumentError.new(arg, args[i]) unless arg.is_a?(args[i])
      end
      _fire_tracepoint(values)
    end

    def provider
      Provider.fetch(@provider_name)
    end

    # Returns true if a tracepoint is currently
    # attached to, indicating we should fire it
    def enabled?; end

    private

    def validate_args(values)
      raise InvalidArgType unless values.all? { |value| VALID_ARGS_TYPES.include?(value) }
    end
  end
end
