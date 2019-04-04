#!/bin/bash
set -x

cd /app

bundle install
bundle exec rake build
bundle exec rake gem
