# frozen_string_literal: true

module StaticTracing
  module Platform
    extend self
    UNSUPPORTED_POST_INSTALL_MESSAGE = %(
    WARNING: You have installed this on an unsupported platform, somehow.

    You should verify for yourself that the behavior on your platform is safe.
    )

    LINUX_POST_INSTALL_MESSAGE = %(
    WARNING: you will need a new kernel (4.14+) that supports eBPF.

    You should use the newest possible version of bpftrace
    ).freeze

    DARWIN_POST_INSTALL_MESSAGE = %(
    WARNING: tracing with dtrace will not work with SIP enabled.

    SIP is enabled by default on recent versions of OSX. You can
    check if SIP is enabled with:

        csrutil status

    If you want to test your probes out locally, you will need to at
    least allow dtrace. To do this, you must reboot into recovery mode
    by holding CMD + R while your Mac is booting. Once it has booted,
    open a terminal and type:

        csrutil clear
        csrutil enable --without-dtrace

    After this, you should be able to use dtrace on the tracepoints you
    define here. If it still doesn't work, you can disable SIP entirely
    but this is not recommended for security purposes.
    ).freeze

    def linux?
      /linux/.match(RUBY_PLATFORM)
    end

    def darwin?
      /darwin/.match(RUBY_PLATFORM)
    end

    def post_install_message
      message = begin
        if linux?
          LINUX_POST_INSTALL_MESSAGE
        elsif darwin?
          DARWIN_POST_INSTALL_MESSAGE
        else
          UNSUPPORTED_POST_INSTALL_MESSAGE
        end
      end
    end
  end
end
