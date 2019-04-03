$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)

require 'mkmf'
require 'ruby-static-tracing/platform'

unless StaticTracing.linux?
end

def platform_dir(platform)
  File.expand_path("../../../ext/ruby-static-tracing/#{platform}/", __FILE__)
end

if StaticTracing.linux?
  abort 'libstapsdt.h is missing, please install libstapsdt' unless find_header('libstapsdt.h')

  have_header 'libstapsdt.h'

  $CFLAGS = "-D_GNU_SOURCE -Wall " # -Werror  complaining
  if ENV.key?('DEBUG')
    $CFLAGS << "-O0 -g -DDEBUG"
  else
    $CFLAGS << "-O3"
  end

  create_makefile('ruby-static-tracing/ruby_static_tracing', platform_dir("linux"))
else
  # FIXME properly stub this.
  # Should have 3 cases:
  #  - Linux, via libstapsdt
  #  - BSD and other dtrace platforms, via libusdt
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
