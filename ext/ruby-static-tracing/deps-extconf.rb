$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)

require 'mkmf'
require 'ruby-static-tracing/platform'

BASE_DIR = File.expand_path(File.dirname(__FILE__)) 
LIB_DIR  = File.expand_path('../../../lib/ruby-static-tracing', __FILE__)

# FIXME have this install libstapsdt
if StaticTracing::Platform.linux?
  File.write "Makefile", <<MAKEFILE
all:
clean:
install:
MAKEFILE
  exit
# We'll build libusdt and install and update linker info
elsif StaticTracing::Platform.darwin?
  # This is a bit of a hack to compile libusdt.dylib
  # and "trick" extconf into thinking it's just another .bundle
  # After installing it, we forcefully update the load path for
  # ruby_static_tracing.bundle to find it in the same directory
  File.write "Makefile", <<MAKEFILE
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
  File.write "Makefile", <<MAKEFILE
all:
clean:
install:
MAKEFILE
  exit
end
