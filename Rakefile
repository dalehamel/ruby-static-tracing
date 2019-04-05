require 'rake/testtask'
require 'bundler/gem_tasks'

GEMSPEC = eval(File.read('ruby-static-tracing.gemspec'))
BASE_DIR = File.expand_path(File.dirname(__FILE__))
DOCKER_DIR = File.join(BASE_DIR, 'docker')
# ==========================================================
# Packaging
# ==========================================================

require 'rubygems/package_task'
Gem::PackageTask.new(GEMSPEC) do |_pkg|
end

# ==========================================================
# Ruby Extension
# ==========================================================

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

# ==========================================================
# Development
# ==========================================================

namespace :vagrant do
  desc "Sets up a vagrant VM, needed for our development environment."
  task :up do
    system("vagrant up")
  end

  desc "Provides a shell within vagrant."
  task :ssh do
    system("vagrant ssh")
  end

  desc "Enters a shell within our development docker image, within vagrant."
  task :shell do
    system("vagrant ssh -c 'cd /vagrant && bundle exec rake docker:shell'")
  end

  desc "Runs tests within the development docker image, within vagrant"
  task :tests do
    system("vagrant ssh -c 'cd /vagrant && bundle exec rake docker:tests'")
  end

  desc "Runs integration tests within the development docker image, within vagrant"
  task :integration do
    system("vagrant ssh -c 'cd /vagrant && bundle exec rake docker:integration'")
  end

  desc "Cleans up the vagrant VM"
  task :clean do
    system("vagrant destroy")
  end
end

# Quick helpers to get a dev env set up
namespace :docker do
  desc "Builds the development docker image"
  task :build do
      system("docker build -f #{File.join(DOCKER_DIR, 'Dockerfile.ci')} #{DOCKER_DIR} -t ruby-static-tracing:latest")
  end

  desc "Runs the development docker image"
  task :run do
    `docker run --privileged --name ruby-static-tracing-#{Time.now.getutc.to_i} -v $(pwd):/app -d ruby-static-tracing:latest /bin/sh -c "sleep infinity"`.strip
    system("docker exec -ti #{latest_running_container_id} /app/vagrant/debugfs.sh")
  end

  desc "Provides a shell within the development docker image"
  task :shell do
    system("docker exec -ti #{latest_running_container_id} bash")
  end

  desc "Runs tests within the development docker image"
  task :tests do
    system("docker exec -ti #{latest_running_container_id} bash -c 'bundle install && bundle exec rake clean && bundle exec rake build && bundle exec rake test'")
  end

  desc "Runs integration tests within the development docker image"
  task :integration do
    system("docker exec -ti #{latest_running_container_id} bash -c 'bundle install && bundle exec rake clean && bundle exec rake build && bundle exec rake integration'")
  end

  desc "Cleans up all development docker images for this project"
  task :clean do
    system("docker container ls --quiet --filter name=ruby-static-tracing* | xargs -I@ docker container kill @")
  end

  desc "Fully set up a development docker image, and get a shell"
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

Rake::TestTask.new do |t|
  t.name = 'integration'
  t.libs << 'integration'
  t.test_files = FileList['integration/**/*_test.rb']
  t.verbose = true
end

# ==========================================================
# Documentation
# ==========================================================
require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include("lib/*.rb", "ext/semian/*.c")
end
