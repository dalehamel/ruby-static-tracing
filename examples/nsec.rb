require 'ruby-static-tracing'

t = StaticTracing::Tracepoint.new('global', 'nsec_latency', Integer)
p = StaticTracing::Provider.fetch(t.provider)
p.enable

loop do
  s = StaticTracing.nsec
  StaticTracing.nsec # profiling this call
  f = StaticTracing.nsec
  t.fire(f-s)
end
