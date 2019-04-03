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
end
