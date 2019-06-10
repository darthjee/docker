#!/bin/bash

cp /usr/local/bundle /home/app/bundle_cache -R
mkdir -p /home/app/bundle/gems/
mkdir -p /home/app/bundle/cache/

bundle install --clean

for PATH in /usr/local/bundle/gems/*; do
  GEM=${PATH##/usr/local/bundle/gems/}
  if [ ! -x /home/app/bundle_cache/gems/$GEM ]; then
    cp $PATH /home/app/bundle/gems/$GEM -R
    cp /usr/local/bundle/cache/$GEM.gem /home/app/bundle/cache -R
    cp /usr/local/bundle/specifications/$GEM.gemspec /home/app/bundle/specifications -R
  fi
done
