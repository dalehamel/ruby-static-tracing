require 'ruby-static-tracing'
STDOUT.sync = true

t = StaticTracing::Tracepoint.new('global', 'hello_test', String)
p = StaticTracing::Provider.fetch(t.provider)
p.enable

Signal.trap('USR2') do
  puts "TRAP #{t.enabled?}"
  t.fire_tracepoint(["Hello world"]) if t.enabled?
  sleep 5
end

loop { puts t.enabled?; sleep 1 }
