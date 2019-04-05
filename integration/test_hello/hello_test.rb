require 'integration_helper'

test_dir = File.expand_path(File.dirname(__FILE__))
Dir.chdir(test_dir)

# FIXME can any of this be generalized / should the convention be encoded?
class RubyStaticTracingTest < MiniTest::Test
  def test_hello
    test_dir = File.expand_path(File.dirname(__FILE__))
    Dir.chdir(test_dir)

    target = CommandRunner.new('bundle exec ruby hello.rb', 1)
    tracer = CommandRunner.new("bpftrace hello.bt -p #{target.pid}", 5)

    # Signal the target to trigger probe firing
    target.usr2(1)
    # Signal bpftrace to exit, flushing output
    tracer.interrupt(1)
    assert_equal(tracer.output, File.read('hello.out'))
  end
end
