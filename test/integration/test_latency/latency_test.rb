# frozen_string_literal: true

require 'integration_helper'

# FIXME: can any of this be generalized / should the convention be encoded?
class LatencyTest < IntegrationTestCase
  def test_latency
    target = command('bundle exec ruby latency.rb', wait: 1)

    # Enable probing
    target.prof(1)

    tracer = TraceRunner.trace('-p', target.pid, script: 'latency', wait: 1)

    # Signal the target to trigger probe firing
    target.usr2(1)

    assert_tracer_output(tracer.output, read_probe_file('latency.out'))
  end
end
