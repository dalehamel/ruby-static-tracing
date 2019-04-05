require 'integration_helper'

# FIXME can any of this be generalized / should the convention be encoded?
class RubyStaticTracingTest < IntegrationTestCase
  def test_hello
    target = command('bundle exec ruby hello.rb', wait: 1)
    tracer = command("bpftrace hello.bt -p #{target.pid}", wait: 5)

    # Signal the target to trigger probe firing
    target.usr2(1)
    # Signal bpftrace to exit, flushing output
    tracer.interrupt(1)
    assert_equal(tracer.output, read_probe_file('hello.out'))
  end
end
