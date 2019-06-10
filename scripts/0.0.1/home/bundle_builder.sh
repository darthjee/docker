#!/bin/bash

cp /usr/local/bundle $HOME_DIR/bundle_cache -R
mkdir -p $HOME_DIR/bundle/gems/
mkdir -p $HOME_DIR/bundle/cache/

bundle install --clean

for PATH in /usr/local/bundle/gems/*; do
  GEM=${PATH##/usr/local/bundle/gems/}
  if [ ! -x $HOME_DIR/bundle_cache/gems/$GEM ]; then
    cp $PATH $HOME_DIR/bundle/gems/$GEM -R
    cp /usr/local/bundle/cache/$GEM.gem $HOME_DIR/bundle/cache -R
    cp /usr/local/bundle/specifications/$GEM.gemspec $HOME_DIR/bundle/specifications -R
  fi
done
