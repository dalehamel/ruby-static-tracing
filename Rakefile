require 'rake/testtask'
require 'bundler/gem_tasks'

GEMSPEC = eval(File.read('ruby-static-tracing.gemspec'))
BASE_DIR = File.expand_path(File.dirname(__FILE__))

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

DOCKER_DIR = File.join(BASE_DIR, 'docker')
# Quick helpers to get a dev env set up
namespace :docker do
  task :build do
      system("docker build -f #{File.join(DOCKER_DIR, 'Dockerfile.ci')} #{DOCKER_DIR} -t ruby-static-tracing:latest")
  end

  task :run do
    `docker run --name ruby-static-tracing-#{Time.now.getutc.to_i} -v $(pwd):/app -d ruby-static-tracing:latest /bin/sh -c "sleep infinity"`.strip
  end

  task :shell do
    system("docker exec -ti #{latest_running_container_id} bash")
  end

  task :tests do
    system("docker exec -ti #{latest_running_container_id} bundle exec rake test")
  end

  task :clean do
    system("docker container ls --quiet --filter name=ruby-static-tracing* | xargs -I@ docker container kill @")
  end

  task :up => [:build, :run, :shell]

  def latest_running_container_id
    container_id = `docker container ls --latest --quiet --filter status=running --filter name=ruby-static-tracing*`.strip
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
