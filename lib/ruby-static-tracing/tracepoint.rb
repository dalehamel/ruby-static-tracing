# frozen_string_literal: true

module StaticTracing
  class Tracepoint #:nodoc:

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

    VALID_ARGS_TYPES = [Integer, String]

    attr_reader :provider, :name, :args

    def initialize(provider, name, *args)
      @provider = provider
      @name = name
      validate_args(args)
      @args = args

      if StaticTracing::Platform.linux?
        tracepoint_initialize(provider, name, args)
      else
        StaticTracing.issue_disabled_tracepoints_warning
      end
    end

    def fire(*values)
      values.each_with_index do |arg, i|
        raise InvalidArgumentError.new(arg, args[i]) unless arg.is_a?(args[i])
      end
      _fire_tracepoint(values)
    end

    def enabled?
    end

    private

    def validate_args(values)
      raise InvalidArgType unless values.all? { |value|  VALID_ARGS_TYPES.include?(value) }
    end
  end
end
