require 'bundler/gem_tasks'

GEMSPEC = eval(File.read('ruby-static-tracing.gemspec'))

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'ruby-static-tracing/platform'
if StaticTracing.linux?
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
task :dockerbuild do
  system('docker build . -t ruby-static-tracing')
end

task :run do
  containerid=`docker run -v $(pwd):/app -d ruby-static-tracing:latest /bin/sh -c "sleep infinity"`.strip
  puts "Entering docker container #{containerid}"
  system("docker exec -ti #{containerid} bash")
end
