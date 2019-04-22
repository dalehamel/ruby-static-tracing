# frozen_string_literal: true

require 'integration_helper'

# FIXME: can any of this be generalized / should the convention be encoded?
class RubyStaticTracingTest < IntegrationTestCase
  def test_hello
    target = command('bundle exec ruby hello.rb', wait: 1)
    tracer = TraceRunner.trace('-p', target.pid, script: 'hello', wait: 1)

    # Signal the target to trigger probe firing
    target.usr2(1)

    assert_tracer_output(tracer.output, read_probe_file('hello.out'))
  end
end
