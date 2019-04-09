require 'integration_helper'

# FIXME can any of this be generalized / should the convention be encoded?
class StacktraceTest < IntegrationTestCase
  def test_stacktrace
    target = command('bundle exec ruby stacktrace.rb', wait: 1)
    # Enable probing
    target.prof(1)

    tracer = TraceRunner.trace('-p', target.pid, script: 'stacktrace', wait: 5)

    # Signal the target to trigger probe firing
    target.usr2(1)

    # Signal bpftrace to exit, flushing output
    tracer.interrupt(1)

    assert_tracer_output(tracer.output, read_probe_file('stacktrace.out'))
  end
end
