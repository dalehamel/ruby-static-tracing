require 'integration_helper'

# FIXME can any of this be generalized / should the convention be encoded?
class LatencyTest < IntegrationTestCase
  def test_latency
    target = command('bundle exec ruby latency.rb', wait: 1)
<<<<<<< HEAD

    # Enable probing
    target.prof(1)

=======
>>>>>>> WIP
    tracer = command("bpftrace latency.bt -p #{target.pid}", wait: 5)

    # Signal the target to trigger probe firing
    target.usr2(1)
<<<<<<< HEAD

    # Signal bpftrace to exit, flushing output
    tracer.interrupt(1)

=======
    # Signal bpftrace to exit, flushing output
    tracer.interrupt(1)
>>>>>>> WIP
    assert_equal(tracer.output, read_probe_file('latency.out'))
  end
end
