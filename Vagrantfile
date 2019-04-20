# frozen_string_literal: true

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/cosmic64'
  config.vm.provider 'virtualbox' do |v|
    v.memory = 4096
    v.cpus = 4
  end
  config.vm.provision 'shell',
                      inline: '/bin/bash /vagrant/vagrant/provision.sh'

  config.vm.provision 'shell',
                      inline: '/bin/bash /vagrant/vagrant/docker.sh'

  config.vm.provision 'shell', inline: 'echo "Vagrant is now provisioned - run \"vagrant ssh\" to access the vm, and \"bundle exec rake docker:shell\" to start a development shell"'
  config.vm.provision 'shell', inline: 'echo -e "Or, to do both of these, just run:\n\tbundle exec rake vagrant:shell"'
end
