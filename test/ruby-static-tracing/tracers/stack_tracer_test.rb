# frozen_string_literal: true

require 'test_helper'
require 'ruby-static-tracing/tracers/stack_tracer'

module StaticTracing
  module Tracers
    class FakeTracePoint
      def initialize(provider, name, klass1, klass2)
        @foo = 1
      end

      def fire(str1, str2)
        str2
      end
    end

    class StackTracerTest < MiniTest::Test
      class Example
        def noop
          true
        end
        StaticTracing::Tracers::StackTracer.register(self, :noop)
      end

      def teardown
        Tracers::StackTracer.disable!
      end

      def test_tracer_method_gets_exposed_to_registered_class
        Tracers::StackTracer.enable!
        StackTracer.expects(:fire_tracepoint)

        @example = Example.new

        assert_equal(true, @example.noop)
      end
    end
  end
end

