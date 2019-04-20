# frozen_string_literal: true

require 'minitest/autorun'
require 'pry-byebug' if ENV['PRY']

require 'tempfile'

CACHED_DTRACE_PATH = File.expand_path("../../../.bin/dtrace", __FILE__).freeze
PIDS = []
def cleanup_pids
  PIDS.each do |p|
    Process.kill('KILL', p)
  rescue Errno::EPERM
  end
end

MiniTest.after_run { cleanup_pids }

module TraceRunner
  module_function

  def trace(*flags, script: nil, wait: nil)
    cmd = ''
    if StaticTracing::Platform.linux?
      cmd = 'bpftrace'
      cmd = [cmd, "#{script}.bt"] if script
    elsif StaticTracing::Platform.darwin?
      cmd = [CACHED_DTRACE_PATH, '-q']
      cmd = [cmd, '-s', "#{script}.dt"] if script
    else
      puts 'WARNING: no supported tracer for this platform'
      return
    end

    cmd = [cmd, flags]

    command = cmd.flatten.join(' ')
    puts command if ENV['DEBUG']
    CommandRunner.new(command, wait)
  end
end

# FIXME: add a "fixtures record" helper to facilitate adding tests / updating fixtures
class CommandRunner
  TRACE_ENV_DEFAULT = {
    'BPFTRACE_STRLEN' => '100' # workaround for https://github.com/iovisor/bpftrace/issues/305
  }.freeze

  attr_reader :pid, :path

  def initialize(command, wait = nil)
    outfile = Tempfile.new('ruby-static-tracing_tmp_out')
    @path = outfile.path
    outfile.unlink
    at_exit { File.unlink(@path) if File.exist?(@path) }

    @pid = Process.spawn(TRACE_ENV_DEFAULT, command, out: [@path, 'w'], err: '/dev/null')
    PIDS << @pid
    sleep wait if wait
  end

  def output
    output = File.read(@path)
    output
  end

  def interrupt(wait = nil)
    Process.kill('INT', @pid)
    sleep wait if wait
  end

  def kill(wait = nil)
    Process.kill('KILL', @pid)
    sleep wait if wait
  end

  def prof(wait = nil)
    Process.kill('SIGPROF', @pid)
    sleep wait if wait
  end

  def usr2(wait = nil)
    Process.kill('USR2', @pid)
    sleep wait if wait
  end
end

class IntegrationTestCase < MiniTest::Test
  def run
    file_directory = location.split('#').last
    test_dir = File.expand_path(file_directory, File.dirname(__FILE__))
    Dir.chdir(test_dir) do
      super
    end
  end

  def command(command, wait: nil)
    CommandRunner.new(command, wait)
  end

  def read_probe_file(file)
    File.read(file)
  end

  def assert_tracer_output(outout, expected_ouput)
    msg = <<~EOF
      Output from tracer:
      #{mu_pp(outout)}

      Expected output:
      #{mu_pp(expected_ouput)}
    EOF
    assert(outout == expected_ouput, msg)
  end
end

def cache_dtrace
  puts <<-eof
  In order to run integration tests on OS X, we need to run
  dtrace with root permissions. To do this, we will ask you for
  sudo access to grant SETUID to a copy of the dtrace binary that
  we will cache in this project directory.

  Once this is done, any time you run integration tests dtrace will
  run as root, but the test suite won't.

  Please enter your sudo password to continue.
  eof
  FileUtils.mkdir_p(File.dirname(CACHED_DTRACE_PATH))
  FileUtils.cp('/usr/sbin/dtrace', CACHED_DTRACE_PATH)
  system("sudo chown root #{CACHED_DTRACE_PATH} && sudo chmod a+s #{CACHED_DTRACE_PATH}")
end

if StaticTracing::Platform.darwin?
  cache_dtrace unless File.exists?(CACHED_DTRACE_PATH)
end
