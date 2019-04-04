Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/cosmic64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
  end
  config.vm.provision "shell",
    inline: "/bin/bash /vagrant/vagrant/provision.sh"
end
