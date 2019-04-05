require 'ruby-static-tracing'
STDOUT.sync = true

class ExpensiveOperation
  def execute
    ([] << 1) * 100000
  end

  StaticTracing::Tracers::LatencyTracer.register(self, :execute)
end

<<<<<<< HEAD
StaticTracing.configure do |config|
  config.add_tracer(StaticTracing::Tracers::LatencyTracer)
end

expensive_operation = ExpensiveOperation.new

Signal.trap('USR2') do
  expensive_operation.execute
end

while true
end

=======
StaticTracing::Tracers::LatencyTracer.enable!

puts "here"

expensive_operation = ExpensiveOperation.new

puts "there"
expensive_operation.execute
puts "boom"
>>>>>>> WIP
