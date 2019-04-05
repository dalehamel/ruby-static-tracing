require 'minitest/autorun'
require 'pry-byebug' if ENV['PRY']

require 'tempfile'

PIDS = []
def cleanup_pids; PIDS.each {|p| Process.kill('KILL', p) } end

MiniTest::Unit.after_tests { cleanup_pids }

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
    Process.kill('INT', @pid)
    sleep wait if wait
  end

  def kill(wait = nil)
    Process.kill('KILL', @pid)
    sleep wait if wait
  end

  def usr2(wait = nil)
    Process.kill('USR2', @pid)
    sleep wait if wait
  end
end
