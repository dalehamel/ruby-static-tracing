#!/bin/bash
cd /vagrant
bundle install
bundle exec rake docker:build
bundle exec rake docker:run

id=$(docker container ls --latest --quiet --filter status=running --filter name=ruby-static-tracing* | tr -d '\n')
docker exec $id bundle install
docker exec $id bundle exec rake build
docker exec $id bundle exec rake gem
