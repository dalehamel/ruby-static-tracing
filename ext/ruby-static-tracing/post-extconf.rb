$LOAD_PATH.unshift File.expand_path("../../../lib", __FILE__)

require 'mkmf'
require 'ruby-static-tracing/platform'

BASE_DIR = File.expand_path(File.dirname(__FILE__)) 
LIB_DIR  = File.expand_path('../../../lib/ruby-static-tracing', __FILE__)

# Linux is a noop
if StaticTracing::Platform.linux?
  File.write "Makefile", <<MAKEFILE
all:
	touch post.so
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
	touch post.bundle
	install_name_tool -change libusdt.dylib @loader_path/../ruby-static-tracing/libusdt.dylib #{File.join(LIB_DIR, 'ruby_static_tracing.bundle')}
clean:
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
