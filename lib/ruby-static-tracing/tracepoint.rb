# frozen_string_literal: true

module StaticTracing
  class Tracepoint #:nodoc:

    class InvalidArgumentError < StandardError; end

    attr_reader :provider, :name, :args

    def initialize(provider, name, *args)
      @provider = provider
      @name = name
      @args = args
    end

    def fire(*values)
      values.each_with_index do |arg, i|
        raise InvalidArgumentError unless arg.is_a?(args[i])
      end
    end

    def enabled?
    end
  end
end
