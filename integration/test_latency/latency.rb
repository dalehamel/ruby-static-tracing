require 'ruby-static-tracing'
STDOUT.sync = true

class ExpensiveOperation
  def execute
    ([] << 1) * 100000
  end

  StaticTracing::Tracers::LatencyTracer.register(self, :execute)
end

StaticTracing::Tracers::LatencyTracer.enable!

puts "here"

expensive_operation = ExpensiveOperation.new

puts "there"
expensive_operation.execute
puts "boom"
