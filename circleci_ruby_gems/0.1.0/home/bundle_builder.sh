#!/bin/bash

cp /usr/local/bundle /home/circleci/bundle_cache -R
mkdir -p /home/circleci/bundle/gems/
mkdir -p /home/circleci/bundle/cache/

bundle install --clean

for PATH in /usr/local/bundle/gems/*; do
  GEM=${PATH##/usr/local/bundle/gems/}
  if [ ! -x /home/circleci/bundle_cache/gems/$GEM ]; then
    cp $PATH /home/circleci/bundle/gems/$GEM -R
    cp /usr/local/bundle/cache/$GEM.gem /home/circleci/bundle/cache -R
    cp /usr/local/bundle/specifications/$GEM.gemspec /home/circleci/bundle/specifications -R
  fi
done
