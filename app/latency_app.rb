# frozen_string_literal: true

require 'ruby-static-tracing'
require 'ruby-static-tracing/tracers/concerns/latency_tracer'

class LatencyApp
  def sleep1
    puts 'Sleeping for 1 second.'
    sleep(1)
  end

  def sleep2
    puts 'Sleeping for 2 seconds.'
    sleep(2)
  end

  def noop
    puts 'Continuing'
  end

  include StaticTracing::Tracer::Concerns::Latency
end

StaticTracing.configure do |config|
  config.add_tracer(StaticTracing::Tracer::Latency)
end

app = LatencyApp.new


loop do
  app.sleep1
  app.sleep2
  app.noop
end
