# frozen_string_literal: true

require 'test_helper'

class DummyClass
  include StaticTracing
end

class RubyStaticTracingTest < MiniTest::Test
  class Example
    def noop; end
  end

  TEST_PROVIDER_NAME = :ruby_static_tracing_test_example

  def setup
    @tp = StaticTracing::Tracepoint.new(TEST_PROVIDER_NAME, 'noop', Integer)
    @tp.provider.enable
  end

  def test_nsec_returns_monotonic_time_in_nanoseconds
    assert(@tp.provider.enabled?)
    Process
      .expects(:clock_gettime)
      .with(Process::CLOCK_MONOTONIC, :nanosecond)

    StaticTracing.nsec
  end

  def test_toggle_tracing
    StaticTracing.enable!
    assert StaticTracing.enabled?
    assert StaticTracing::Provider.fetch(TEST_PROVIDER_NAME).enabled?
    StaticTracing.toggle_tracing!
    refute StaticTracing.enabled?
    refute StaticTracing::Provider.fetch(TEST_PROVIDER_NAME).enabled?
    StaticTracing.toggle_tracing!
    assert StaticTracing.enabled?
    assert StaticTracing::Provider.fetch(TEST_PROVIDER_NAME).enabled?
  end

  def teardown
    @tp.provider.disable
    assert !@tp.provider.enabled?
  end
end
