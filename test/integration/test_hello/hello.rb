# frozen_string_literal: true

require 'ruby-static-tracing'
STDOUT.sync = true

t = StaticTracing::Tracepoint.new('global', 'hello_test', String)
puts t.provider.enable

Signal.trap('USR2') do
  puts "TRAP #{t.enabled?}"
  t.fire('Hello world') if t.enabled?
  sleep 2
end

loop { puts t.enabled?; sleep 1 }
