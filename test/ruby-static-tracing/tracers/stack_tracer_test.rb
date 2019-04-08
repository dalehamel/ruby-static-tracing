# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  module Tracers
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
        StaticTracing::Tracepoint.any_instance.expects(:fire).once

        @example = Example.new

        assert_equal(true, @example.noop)
      end

      def test_methods_with_args_still_work
        Tracers::StackTracer.enable!
        StaticTracing::Tracepoint.any_instance.expects(:fire).once

        @example = Example.new

        assert_equal(1, @example.noop_with_arg(1))
      end

      def test_methods_with_blocks_still_work
        Tracers::StackTracer.enable!
        StaticTracing::Tracepoint.any_instance.expects(:fire).once

        @example = Example.new

        assert_equal(1, @example.noop_with_block { 1 } )
      end

      def test_methods_with_blocks_and_args_still_work
        Tracers::StackTracer.enable!
        StaticTracing::Tracepoint.any_instance.expects(:fire).once

        @example = Example.new

        assert_equal(1, @example.noop_with_arg_and_block(1){ |a| a })
      end
    end
  end
end

