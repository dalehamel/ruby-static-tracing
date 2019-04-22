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
