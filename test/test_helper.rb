# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'mocha/minitest'
require 'pry-byebug' if ENV['PRY']
require_relative '../lib/ruby-static-tracing.rb'
