# frozen_string_literal: true

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
