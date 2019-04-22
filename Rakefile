# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

GEMSPEC    = eval(File.read('ruby-static-tracing.gemspec'))
BASE_DIR   = __dir__
DOCKER_DIR = File.join(BASE_DIR, 'docker')
EXT_DIR    = File.join(BASE_DIR, 'ext/ruby-static-tracing')
LIB_DIR    = File.join(BASE_DIR, 'lib', 'ruby-static-tracing')
# ==========================================================
# Packaging
# ==========================================================

require 'rubygems/package_task'
Gem::PackageTask.new(GEMSPEC) do |_pkg|
end

# ==========================================================
# Ruby Extension
# ==========================================================

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'ruby-static-tracing/platform'
require 'ruby-static-tracing/version'
if StaticTracing::Platform.supported_platform?
  require 'rake/extensiontask'

  # Task to compile external dep, but let them use their own makefiles
  Rake::ExtensionTask.new do |ext|
    ext.name    = 'deps'
    ext.ext_dir = 'ext/ruby-static-tracing/lib'
    ext.lib_dir = 'lib/ruby-static-tracing'
    ext.config_script = 'deps-extconf.rb'
  end

  Rake::ExtensionTask.new('ruby_static_tracing', GEMSPEC) do |ext|
    ext.ext_dir = 'ext/ruby-static-tracing'
    ext.lib_dir = 'lib/ruby-static-tracing'
  end

  # Task for "post install" of libraries
  Rake::ExtensionTask.new do |ext|
    ext.name    = 'post'
    ext.ext_dir = 'ext/ruby-static-tracing/lib'
    ext.lib_dir = 'lib/ruby-static-tracing'
    ext.config_script = 'post-extconf.rb'
  end

  task fresh:   ['deps:clean', :clean]
  task compile: [:fresh, 'compile:deps', 'compile:ruby_static_tracing', 'compile:post']
  task build:   %i[fresh compile]
else
  task :build do
  end
end

# ==========================================================
# Development
# ==========================================================

namespace :deps do
  task :get do
    system('git submodule init')
    system('git submodule update')
  end

  task :clean do
    system("cd #{File.join(EXT_DIR, 'lib', 'libusdt')} && make clean")
    system("cd #{File.join(EXT_DIR, 'lib', 'libstapsdt')} && make clean")
  end
end

namespace :vagrant do
  desc 'Sets up a vagrant VM, needed for our development environment.'
  task :up do
    system('vagrant up')
  end

  desc 'Provides a shell within vagrant.'
  task :ssh do
    system('vagrant ssh')
  end

  desc 'Enters a shell within our development docker image, within vagrant.'
  task :shell do
    system("vagrant ssh -c 'cd /vagrant && bundle exec rake docker:shell'")
  end

  desc 'Runs tests within the development docker image, within vagrant'
  task :tests do
    system("vagrant ssh -c 'cd /vagrant && bundle exec rake docker:tests'")
  end

  desc 'Runs integration tests within the development docker image, within vagrant'
  task :integration do
    system("vagrant ssh -c 'cd /vagrant && bundle exec rake docker:integration'")
  end

  desc 'Cleans up the vagrant VM'
  task :clean do
    system('vagrant destroy')
  end
end

# Quick helpers to get a dev env set up
namespace :docker do
  desc 'Builds the development docker image'
  task :build do
    system("docker build -f #{File.join(DOCKER_DIR, 'Dockerfile.ci')} #{DOCKER_DIR} -t quay.io/dalehamel/ruby-static-tracing")
  end

  desc 'Runs the development docker image'
  task :run do
    `docker run --privileged --name ruby-static-tracing-#{Time.now.getutc.to_i} -v $(pwd):/app -d quay.io/dalehamel/ruby-static-tracing:latest /bin/sh -c "sleep infinity"`.strip
    system("docker exec -ti #{latest_running_container_id} /app/vagrant/debugfs.sh")
  end

  desc 'Provides a shell within the development docker image'
  task :shell do
    system("docker exec -ti #{latest_running_container_id} bash")
  end

  desc 'Build and install the gem'
  task :install do
    system("docker exec -ti #{latest_running_container_id} bash -c 'bundle install && bundle exec rake install'")
  end
  desc 'Runs integration tests within the development docker image'
  task :integration do
    system("docker exec -ti #{latest_running_container_id} bash -c 'bundle install && bundle exec rake clean && bundle exec rake build && bundle exec rake integration'")
  end

  desc 'Wrap running test in docker'
  task :test do
    exit system("docker exec -ti #{latest_running_container_id} \
         bash -c 'mv vendor vendor.bak; bundle install && \
                 bundle exec rake test; err=$?;
                 rm -rf vendor; mv vendor.bak vendor;
                 exit $err'")
  end

  desc 'Wrap running Rubocop in docker'
  task :rubocop do
    exit system("docker exec -ti #{latest_running_container_id} \
         bash -c 'mv vendor ../vendor.bak; bundle install && \
                 bundle exec rake clean;
                 bundle exec rake rubocop; err=$?;
                 rm -rf vendor; mv ../vendor.bak vendor;
                 exit $err'")
  end

  desc 'Check C files for linting issues'
  task :clangfmt do
    exit system("docker exec -ti #{latest_running_container_id} \
         bash -c 'mv vendor vendor.bak; bundle install && \
                 bundle exec rake clangfmt; err=$?;
                 rm -rf vendor; mv vendor.bak vendor;
                 exit $err'")
  end

  desc 'Cleans up all development docker images for this project'
  task :clean do
    system('docker container ls --quiet --filter name=ruby-static-tracing* | xargs -I@ docker container kill @')
  end

  desc 'Pulls development image'
  task :pull do
    system('docker pull quay.io/dalehamel/ruby-static-tracing')
  end

  desc 'Push development image'
  task :push do
    system('docker push quay.io/dalehamel/ruby-static-tracing')
  end

  desc 'Fully set up a development docker image, and get a shell'
  task up: %i[build run shell]

  def latest_running_container_id
    container_id = `docker container ls --latest --quiet --filter status=running --filter name=ruby-static-tracing*`.strip
    if container_id.empty?
      raise 'No containers running, please run rake docker:run and then retry this task'
    else
      container_id
    end
  end
end

namespace :new do
  desc 'Scaffold a new integration test'
  task :integration_test, [:test] do |_t, args|
    test_name = args[:test]
    integration_test_directory = 'test/integration'

    Dir.chdir(integration_test_directory) do
      test_folder = "test_#{test_name}"
      FileUtils.mkdir("test_#{test_name}")

      Dir.chdir(test_folder) do
        File.open("#{test_folder}.rb", 'w') do |file|
          file.write(test_scaffold(test_name))
        end
        FileUtils.touch("#{test_name}.bt")
        FileUtils.touch("#{test_name}.out")
        File.open("#{test_name}.rb", 'w') do |file|
          file.write(basic_script)
        end
      end
    end
  end

  def test_scaffold(test_name)
    <<~TEST
      require 'integration_helper'
       class #{test_name.capitalize}Test < IntegrationTestCase
        def test_#{test_name}
        end
      end
    TEST
  end

  def basic_script
    <<~SCRIPT
      require 'ruby-static-tracing'
      STDOUT.sync = true

    SCRIPT
  end
end

namespace :gem do
  task :push do
    system("gem push pkg/ruby-static-tracing-#{StaticTracing::VERSION}.gem")
  end
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb'].exclude(/integration/)
  t.verbose = true
end

Rake::TestTask.new do |t|
  t.name = 'integration'
  t.libs << 'test/integration'
  t.test_files = FileList['test/integration/**/*_test.rb']
  t.verbose = true
end

RuboCop::RakeTask.new

task :clangfmt do
  diffs = []
  %w[linux darwin include].each do |dir|
    Dir["#{File.join(EXT_DIR, dir)}/*.{h,c}"].each do |src|
      tmp = "/tmp/#{src.tr('/', '_')}"
      system("clang-format #{src} > #{tmp}")
      # system("clang-format -i #{src}")
      diff = `diff #{src} #{tmp}`
      system("rm -f #{tmp}")
      unless diff.lines.empty?
        puts "Diff on #{tmp} #{diff}"
        diffs << diff.lines
      end
    end
  end
  diffcount = diffs.flatten.length
  if diffcount > 0
    puts "clang-format check failed, #{diffcount} differences"
    exit 1
  else
    exit 0
  end
end

# ==========================================================
# Documentation
# ==========================================================
require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include('lib/**/*.rb',
                          'ext/ruby-static-tracing/linux/*.c',
                          'ext/ruby-static-tracing/linux/*.h')
end
