require 'minitest/autorun'
require 'pry-byebug' if ENV['PRY']

require 'tempfile'

PIDS = []
def cleanup_pids
  PIDS.each do |p| 
    Process.kill('KILL', p)
  rescue Errno::EPERM
  end
end

MiniTest::Unit.after_tests { cleanup_pids }

module TraceRunner
  extend self

  def trace(*flags, script: nil, wait: nil)
    cmd = ""
    if StaticTracing::Platform.linux?
      cmd = "bpftrace"
      cmd = [cmd, "#{script}.bt"] if script
    elsif StaticTracing::Platform.darwin?
      cmd = ['sudo', 'dtrace', '-q'] # FIXME find a way to enter sudo at start of test run to avoid timeouts
      cmd = [cmd, '-s', "#{script}.dt"] if script
    else
      puts "WARNING: no supported tracer for this platform"
      return
    end

    cmd = [cmd, flags]

    command = cmd.flatten.join(' ')
    puts command if ENV['DEBUG']
    CommandRunner.new(command, wait)
  end
end

# FIXME add a "fixtures record" helper to facilitate adding tests / updating fixtures
class CommandRunner
  attr_reader :pid, :path

  def initialize(command, wait = nil)
    outfile = Tempfile.new('ruby-static-tracing_tmp_out')
    @path = outfile.path
    outfile.unlink
    at_exit { File.unlink(@path) if File.exists?(@path) }

    @pid = Process.spawn(command, :out=>[@path, "w"])
    PIDS << @pid
    sleep wait if wait
  end

  def output
    output = File.read(@path)
    return output
  end

  def interrupt(wait = nil)
    if StaticTracing::Platform.darwin?
      # dtrace runs as root and must be signaled by root
      system("sudo kill -INT #{@pid}")
    else
      Process.kill('INT', @pid)
    end
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
