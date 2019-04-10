#!/usr/bin/env ruby

require 'ruby-static-tracing'

t = StaticTracing::Tracepoint.new('global', 'nsec_latency', Integer)
p = StaticTracing::Provider.fetch(t.provider)
p.enable

loop do
  s = StaticTracing.nsec
  StaticTracing.nsec
  f = StaticTracing.nsec
  t.fire(f-s)
  sleep 0.001
end
