# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'ruby-static-tracing/version'
require 'ruby-static-tracing/platform'

post_install_message = <<~eof
  This is alpha quality and not suitable for production use
  ... usless you're feeling bold ;)

  If you find any bugs, please file them at:
  	github.com/shopify/ruby-static-tracing
eof

Gem::Specification.new do |s|
  s.name = 'ruby-static-tracing'
  s.version = StaticTracing::VERSION
  s.summary = 'USDT tracing for Ruby'
  s.post_install_message = post_install_message
  s.description = <<-DOC
    A Ruby C extension that enables defining static tracepoints
    from within a ruby context.
  DOC
  s.homepage = 'https://github.com/dalehamel/ruby-static-tracing'
  s.authors = ['Dale Hamel']
  s.email = 'dale.hamel@srvthe.net'
  s.license = 'MIT'

  s.files = Dir['{lib,ext}/**/**/*.{rb,h,c,s}'] +
            Dir['ext/ruby-static-tracing/lib/libusdt/Makefile'] +
            Dir['ext/ruby-static-tracing/lib/libstapsdt/Makefile'] +
            s.extensions = ['ext/ruby-static-tracing/lib/deps-extconf.rb',
                            'ext/ruby-static-tracing/extconf.rb',
                            'ext/ruby-static-tracing/lib/post-extconf.rb']
  s.add_dependency('unmixer')
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rake', '< 11.0'
  s.add_development_dependency 'rake-compiler', '~> 0.9'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
end
