# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)

require 'mkmf'
require 'ruby-static-tracing/platform'

BASE_DIR = __dir__
LIB_DIR  = File.expand_path('../../../lib/ruby-static-tracing', __dir__)

# FIXME: have this install libstapsdt
if StaticTracing::Platform.linux?
  # This is a bit of a hack to compile libstapsdt.so
  # and "trick" extconf into thinking it's just another .so
  File.write 'Makefile', <<~MAKEFILE
    all:
    	cd #{File.join(BASE_DIR, 'libstapsdt')} && make CFLAGS_EXTRA=-DLIBSTAPSDT_MEMORY_BACKED_FD
    	touch deps.so # HACK
    	cp #{File.join(BASE_DIR, 'libstapsdt', 'out/libstapsdt.so.0')} #{LIB_DIR}
    	cd #{LIB_DIR} && ln -sf libstapsdt.so.0 libstapsdt.so
    clean:
    	cd #{File.join(BASE_DIR, 'libstapsdt')} && make clean
    install:
  MAKEFILE
  exit
# We'll build libusdt and install and update linker info
elsif StaticTracing::Platform.darwin?
  # This is a bit of a hack to compile libusdt.dylib
  # and "trick" extconf into thinking it's just another .bundle
  # After installing it (in post-extconf), we forcefully update the load path for
  # ruby_static_tracing.bundle to find it in the same directory
  File.write 'Makefile', <<~MAKEFILE
    all:
    	cd #{File.join(BASE_DIR, 'libusdt')} && make libusdt.dylib
    	touch deps.bundle # HACK
    	cp #{File.join(BASE_DIR, 'libusdt', 'libusdt.dylib')} #{LIB_DIR}
    clean:
    	cd #{File.join(BASE_DIR, 'libusdt')} && make clean
    install:
  MAKEFILE
  exit
else
  #  - Stub, for other platforms that we don't support, we write an empty makefile
  File.write 'Makefile', <<~MAKEFILE
    all:
    clean:
    install:
  MAKEFILE
  exit
end
