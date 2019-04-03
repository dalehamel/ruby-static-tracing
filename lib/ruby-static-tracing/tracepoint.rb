# frozen_string_literal: true

module StaticTracing
  class Tracepoint #:nodoc:

    class InvalidArgumentError < StandardError; end
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
        raise InvalidArgumentError unless arg.is_a?(args[i])
      end
    end

    def enabled?
    end

    private

    def validate_args(values)
      raise InvalidArgType unless values.all? { |value|  VALID_ARGS_TYPES.include?(value) }
    end
  end
end
