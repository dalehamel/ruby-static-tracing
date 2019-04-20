# frozen_string_literal: true

require 'ruby-static-tracing'
STDOUT.sync = true

class StacktraceOperation
  def execute
    1 + 1
  end

  def call
    execute
  end

  StaticTracing::Tracer::Stack.register(self, :call)
end

StaticTracing.configure do |config|
  config.add_tracer(StaticTracing::Tracer::Stack)
end

stack_operation = StacktraceOperation.new

Signal.trap('USR2') do
  stack_operation.call
end

loop do
end
