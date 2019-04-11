# frozen_string_literal: true

require 'logger'

require 'ruby-static-tracing/version'
require 'ruby-static-tracing/platform'
require 'ruby-static-tracing/provider'
require 'ruby-static-tracing/tracepoint'
require 'ruby-static-tracing/tracepoints'
require 'ruby-static-tracing/configuration'
require 'ruby-static-tracing/tracer'
require 'ruby-static-tracing/tracers'

# FIXME Including StaticTracing should cause every method in a module or class to be registered
# Implement this by introspecting all methods on the includor, and wrapping them.
module StaticTracing
  extend self

  BaseError = Class.new(StandardError)
  USDTError = Class.new(BaseError)
  InternalError = Class.new(BaseError)

  attr_accessor :logger

  self.logger = Logger.new(STDERR)

  def issue_disabled_tracepoints_warning
    return if defined?(@warning_issued)
    @warning_issued = true
    logger.info("USDT tracepoints are not presently supported supported on #{RUBY_PLATFORM} - all operations will no-op")
  end

  # Efficiently return the current monotonic clocktime.
  # Wraps libc clock_gettime
  # The overhead of this is tested to be on the order of 10 microseconds under normal conditions
  # You should inline this method in your tracer to avoid an extra method call.
  def nsec
    Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
  end

  # Should indicate if static tracing is enabled - a global constant
  def enabled?
    !!@enabled
  end

  # Overwrite the definition of all functions that are enabled
  # with a wrapped version that has tracing enabled
  def enable!
    StaticTracing::Tracers.enable!
    StaticTracing::Provider.enable!
    @enabled = true
  end

  # Overwrite the definition of all functions to their original definition,
  # no longer wrapping them
  def disable!
    StaticTracing::Tracers.disable!
    StaticTracing::Provider.disable!
    @enabled = false
  end

  def toggle_tracing!
    enabled? ? disable! : enable!
  end

  def configure
    yield Configuration.instance
  end
end

require 'ruby-static-tracing/ruby_static_tracing' if StaticTracing::Platform.linux? || StaticTracing::Platform.darwin?
