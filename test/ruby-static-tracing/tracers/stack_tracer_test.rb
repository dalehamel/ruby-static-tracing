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

        def noop_with_arg(foo)
          foo
        end

        def noop_with_block
          yield
        end

        def noop_with_arg_and_block(foo)
          yield foo
        end

        StaticTracing::Tracers::StackTracer
          .register(self, :noop, :noop_with_arg, :noop_with_block,
                   :noop_with_arg_and_block)
      end

      def teardown
        Tracers::StackTracer.disable!
      end

      def test_basic_methods_fire_tracepoints
        Tracers::StackTracer.enable!
        StackTracer.expects(:fire_tracepoint).with(:noop, anything)

        @example = Example.new

        assert_equal(true, @example.noop)
      end

      def test_methods_with_args_still_work
        Tracers::StackTracer.enable!
        StackTracer.expects(:fire_tracepoint).with(:noop_with_arg, anything)

        @example = Example.new

        assert_equal(1, @example.noop_with_arg(1))
      end

      def test_methods_with_blocks_still_work
        Tracers::StackTracer.enable!
        StackTracer.expects(:fire_tracepoint).with(:noop_with_block, anything)

        @example = Example.new

        assert_equal(1, @example.noop_with_block { 1 } )
      end

      def test_methods_with_blocks_and_args_still_work
        Tracers::StackTracer.enable!
        StackTracer.expects(:fire_tracepoint)
          .with(:noop_with_arg_and_block, anything)

        @example = Example.new

        assert_equal(1, @example.noop_with_arg_and_block(1){ |a| a })
      end
    end
  end
end

