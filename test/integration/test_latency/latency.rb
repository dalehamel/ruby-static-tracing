# frozen_string_literal: true

require 'ruby-static-tracing'
STDOUT.sync = true

class ExpensiveOperation
  def execute
    ([] << 1) * 100_000
  end

  StaticTracing::Tracer::Latency.register(self, :execute)
end

StaticTracing.configure do |config|
  config.add_tracer(StaticTracing::Tracer::Latency)
end

expensive_operation = ExpensiveOperation.new

Signal.trap('USR2') do
  expensive_operation.execute
end

loop do
end
