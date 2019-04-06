$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)

require 'mkmf'
require 'ruby-static-tracing/platform'

BASE_DIR=File.expand_path(File.dirname(__FILE__)) 

MKMF_TARGET='ruby-static-tracing/ruby_static_tracing'

def platform_dir(platform)
  File.expand_path("../../../ext/ruby-static-tracing/#{platform}/", __FILE__)
end

def lib_dir
  File.expand_path("../../../lib/ruby-static-tracing/", __FILE__)
end
#  - Linux, via libstapsdt
if StaticTracing::Platform.linux?
  abort 'libstapsdt.h is missing, please install libstapsdt' unless find_header('libstapsdt.h')

  have_header 'libstapsdt.h'

  unless have_library('stapsdt')
    abort "libstapsdt is missing, please install it"
  end

  $CFLAGS = "-D_GNU_SOURCE -Wall " # -Werror  complaining
  if ENV.key?('DEBUG')
    $CFLAGS << "-O0 -g -DDEBUG"
  else
    $CFLAGS << "-O3"
  end

  create_makefile(MKMF_TARGET, platform_dir("linux"))

#  - Darwin/BSD and other dtrace platforms, via libusdt
elsif StaticTracing::Platform.darwin?
  abort 'dtrace is missing, this platform is not supported' unless have_library("dtrace", "dtrace_open")

  system("cd libusdt && make")
  LIB_DIRS = [File.join(BASE_DIR, 'libusdt'), RbConfig::CONFIG['libdir']]
  HEADER_DIRS = [
                 File.join(BASE_DIR, 'include'),
                 File.join(BASE_DIR, 'libusdt'),
                 RbConfig::CONFIG['includedir']
                ]

  dir_config(MKMF_TARGET, HEADER_DIRS, LIB_DIRS)
  
  have_header('usdt.h')
  have_library('usdt')

  $CFLAGS = "-D_GNU_SOURCE -Wall " # -Werror  complaining
  if ENV.key?('DEBUG')
    $CFLAGS << "-O0 -g -DDEBUG"
  else
    $CFLAGS << "-O3"
  end

  create_makefile(MKMF_TARGET, platform_dir('darwin'))
else
  #  - Stub, for other platforms that support neither
  # for now, we will yolo stub this to leave room to handle platforms
  # that support properly support conventional dtrace
  File.write "Makefile", <<MAKEFILE
all:
clean:
install:
MAKEFILE
  exit
end
