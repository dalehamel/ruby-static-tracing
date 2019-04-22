# frozen_string_literal: true

require 'test_helper'

class DummyClass
  include StaticTracing
end

class RubyStaticTracingTest < MiniTest::Test
  class Example
    def noop; end
    StaticTracing::Tracer::Latency.register(self, :noop)
  end

  def test_nsec_returns_monotonic_time_in_nanoseconds
    Process
      .expects(:clock_gettime)
      .with(Process::CLOCK_MONOTONIC, :nanosecond)

    StaticTracing.nsec
  end

  def test_toggle_tracing
    StaticTracing.enable!
    assert StaticTracing.enabled?
    assert StaticTracing::Provider.fetch('ruby_static_tracing_test_example').enabled?
    StaticTracing.toggle_tracing!
    refute StaticTracing.enabled?
    refute StaticTracing::Provider.fetch('ruby_static_tracing_test_example').enabled?
    StaticTracing.toggle_tracing!
    assert StaticTracing.enabled?
    assert StaticTracing::Provider.fetch('ruby_static_tracing_test_example').enabled?
  end
end
