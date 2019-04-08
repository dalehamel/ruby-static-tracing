require 'ruby-static-tracing'
STDOUT.sync = true

class StacktraceOperation
  def execute
    1 + 1
  end

  def call
    execute
  end

  StaticTracing::Tracers::StackTracer.register(self, :call)
end

StaticTracing.configure do |config|
  config.add_tracer(StaticTracing::Tracers::StackTracer)
end

stack_operation = StacktraceOperation.new

Signal.trap('USR2') do
  stack_operation.call
end

while true
end
