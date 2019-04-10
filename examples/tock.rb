#!/usr/bin/env ruby

require 'ruby-static-tracing'

DEBUG = ENV['DEBUG']

t = StaticTracing::Tracepoint.new('global', 'hello_nsec', Integer, String)

p = StaticTracing::Provider.fetch(t.provider)
p.enable
l = StaticTracing.nsec

while true do
  i = StaticTracing.nsec
  puts "iteration: #{i-l} ns" if DEBUG
  l = i
  if t.enabled?
    d = StaticTracing.nsec
    puts "enabled: #{d-i} ns" if DEBUG
    t.fire(StaticTracing.nsec, "Hello world")
    f = StaticTracing.nsec
    puts "fire: #{f-i} ns" if DEBUG
    puts "Probe fired!"
  else
    puts "Not enabled"
  end
  sleep 1
end
