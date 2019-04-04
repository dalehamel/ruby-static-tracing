#!/usr/bin/env ruby
require 'ruby-static-tracing'

t = StaticTracing::Tracepoint.new('global', 'hello_nsec', Integer, String)

p = StaticTracing::Provider.fetch(t.provider)
p.enable

while true do
  if t.enabled?
    t.fire_tracepoint([StaticTracing.nsec, "Hello world"])
    puts "Probe fired!"
  else
    puts "Not enabled"
  end
  sleep 1
end
