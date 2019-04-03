require 'rake/testtask'
require 'bundler/gem_tasks'

GEMSPEC = eval(File.read('ruby-static-tracing.gemspec'))

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'ruby-static-tracing/platform'
if StaticTracing::Platform.linux?
  require 'rake/extensiontask'
  Rake::ExtensionTask.new('ruby_static_tracing', GEMSPEC) do |ext|
    ext.ext_dir = 'ext/ruby-static-tracing'
    ext.lib_dir = 'lib/ruby-static-tracing'
  end
  task build: :compile
else
  task :build do
  end
end

# Quick helpers to get a dev env set up
namespace :docker do
  task :build do
    system('docker build . -t ruby-static-tracing')
  end

  task :run do
    `docker run -v $(pwd):/app -d ruby-static-tracing:latest /bin/sh -c "sleep infinity"`.strip
  end

  task :shell do
    system("docker exec -ti #{latest_running_container_id} bash")
  end

  task :tests do
    system("docker exec -ti #{latest_running_container_id} bundle exec rake test")
  end

  task :remove_containers do
    system("docker container ls --quiet | xargs docker container kill")
  end

  def latest_running_container_id
    container_id = `docker container ls --latest --quiet --filter status=running`.strip
    if container_id.empty?
      raise "No containers running, please run rake docker:run and then retry this task"
    else
      container_id
    end
  end
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
