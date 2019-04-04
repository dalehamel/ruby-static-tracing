#!/bin/bash

set -x

cd /vagrant
bundle install
bundle exec rake docker:build
bundle exec rake docker:run

id=$(docker container ls --latest --quiet --filter status=running --filter name=ruby-static-tracing* | tr -d '\n')
docker exec $id /app/vagrant/debugfs.sh
docker exec $id /app/vagrant/bundle.sh
