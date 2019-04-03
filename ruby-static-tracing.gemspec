$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'ruby-static-tracing/version'
require 'ruby-static-tracing/platform'

Gem::Specification.new do |s|
  s.name = 'ruby-static-tracing'
  s.version = StaticTracing::VERSION
  s.summary = 'USDT tracing for Ruby'
  s.description = <<-DOC
    A Ruby C extension that enables defining static tracepoints
    from within a ruby context. 
  DOC
  s.homepage = 'https://github.com/dalehamel/ruby-static-tracing'
  s.authors = ['Dale Hamel']
  s.email = 'dale.hamel@srvthe.net'
  s.license = 'MIT'

  s.files = Dir['{lib,ext}/**/**/*.{rb,h,c}']
  s.extensions = ['ext/ruby-static-tracing/extconf.rb']
  s.add_development_dependency 'rake-compiler', '~> 0.9'
  s.add_development_dependency 'rake', '< 11.0'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pry-byebug'
end
