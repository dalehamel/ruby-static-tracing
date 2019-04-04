#!/bin/bash

set -x

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo echo "deb https://download.docker.com/linux/ubuntu cosmic stable" | sudo tee > /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo apt-get install -y ruby ruby-dev build-essential
sudo gem install bundler:1.17.3
sudo usermod -a -G docker vagrant

echo "cd /vagrant" >> /home/vagrant/.bashrc
echo -e "You are running in the Vagrant VM.\nTo enter the dev env, you must run:\n\tbundle exec rake docker:shell" | sudo tee > /etc/motd
