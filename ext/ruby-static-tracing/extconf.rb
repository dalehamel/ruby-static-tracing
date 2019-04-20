# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__).freeze

require 'mkmf'
require 'ruby-static-tracing/platform'

BASE_DIR = __dir__
LIB_DIR = File.expand_path('../../lib/ruby-static-tracing', __dir__)

MKMF_TARGET = 'ruby-static-tracing/ruby_static_tracing'

def platform_dir(platform)
  File.expand_path("../../../ext/ruby-static-tracing/#{platform}/", __FILE__)
end

def lib_dir
  File.expand_path('../../lib/ruby-static-tracing', __dir__)
end
#  - Linux, via libstapsdt
if StaticTracing::Platform.linux?

  LIB_DIRS = [LIB_DIR, RbConfig::CONFIG['libdir']].freeze
  HEADER_DIRS = [
    File.join(BASE_DIR, 'include'),
    File.join(BASE_DIR, 'lib', 'libstapsdt', 'src'),
    RbConfig::CONFIG['includedir']
  ].freeze

  puts HEADER_DIRS.inspect
  dir_config(MKMF_TARGET, HEADER_DIRS, LIB_DIRS)

  abort 'libstapsdt.h is missing, please install libstapsdt' unless find_header('libstapsdt.h')
  have_header 'libstapsdt.h'
  have_header 'ruby_static_tracing.h'

  unless have_library('stapsdt')
    abort 'libstapsdt is missing, please install it'
  end

  $CFLAGS = '-D_GNU_SOURCE -Wall ' # -Werror  complaining
  $CFLAGS += if ENV.key?('DEBUG')
               '-O0 -g -DDEBUG'
             else
               '-O3'
             end

  $LDFLAGS += " -Wl,-rpath='\$\$ORIGIN/../ruby-static-tracing' "

  create_makefile(MKMF_TARGET, platform_dir('linux'))

#  - Darwin/BSD and other dtrace platforms, via libusdt
elsif StaticTracing::Platform.darwin?
  abort 'dtrace is missing, this platform is not supported' unless have_library('dtrace', 'dtrace_open')

  LIB_DIRS = [LIB_DIR, RbConfig::CONFIG['libdir']].freeze
  puts LIB_DIRS.inspect
  HEADER_DIRS = [
    File.join(BASE_DIR, 'include'),
    File.join(BASE_DIR, 'lib', 'libusdt'),
    RbConfig::CONFIG['includedir']
  ].freeze

  dir_config(MKMF_TARGET, HEADER_DIRS, LIB_DIRS)

  have_header('usdt.h')
  abort 'ERROR: libusdt is required. It is included, so this failure is an error.' unless have_library('usdt')

  $CFLAGS = '-D_GNU_SOURCE -Wall ' # -Werror  complaining
  $CFLAGS << if ENV.key?('DEBUG')
               '-O0 -g -DDEBUG'
             else
               '-O3'
             end

  create_makefile(MKMF_TARGET, platform_dir('darwin'))
else
  #  - Stub, for other platforms that support neither
  # for now, we will yolo stub this to leave room to handle platforms
  # that support properly support conventional dtrace
  File.write 'Makefile', <<~MAKEFILE
    all:
    clean:
    install:
  MAKEFILE
  exit
end
