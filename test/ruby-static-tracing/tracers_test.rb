# frozen_string_literal: true

require 'test_helper'

module StaticTracing
  class TracersTest < MiniTest::Test
    def teardown
      Tracers.clean
    end

    def test_add_raises_error_if_not_a_valid_tracer
      assert_raises(StaticTracing::Tracers::InvalidTracerError) do
        Tracers.add(String)
      end
    end

    def test_add_a_valid_tracer
      Tracers.add(StaticTracing::Tracer::Latency)

      StaticTracing::Tracer::Latency.expects(:enable!)
      Tracers.enable!

      StaticTracing::Tracer::Latency.expects(:disable!)
      Tracers.disable!
    end
  end
end
