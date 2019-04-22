# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

require 'tasks/docker'
require 'tasks/vagrant'

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
  # FIXME: add darwin docs
  rdoc.rdoc_files.include('lib/**/*.rb',
                          'ext/ruby-static-tracing/linux/*.c',
                          'ext/ruby-static-tracing/linux/*.h')
end
