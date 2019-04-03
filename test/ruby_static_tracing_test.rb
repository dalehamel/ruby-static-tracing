# frozen_string_literal: true

require 'test_helper'

class DummyClass
  include StaticTracing
end

class RubyStaticTracingTest < MiniTest::Test
  def test_nsec_returns_monotonic_time_in_nanoseconds
    Process
      .expects(:clock_gettime)
      .with(Process::CLOCK_MONOTONIC, :nanosecond)

    StaticTracing.nsec
  end

  def test_toggle_tracing
    StaticTracing.enable!
    assert StaticTracing.enabled?
    StaticTracing.toggle_tracing!
    refute StaticTracing.enabled?
    StaticTracing.toggle_tracing!
    assert StaticTracing.enabled?
  end
end
