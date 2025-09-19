#!/bin/bash

if [ ! $APP_DIR ]; then
  APP_DIR=$HOME_DIR/app
fi

GLOBAL_CACHE_PATH=/usr/local/share/.cache/yarn
USER_CACHE_PATH=$HOME_DIR/yarn/cached/

function createFolders() {
  mkdir -p $GLOBAL_CACHE_PATH
  mkdir -p $USER_CACHE_PATH
}

function installPackages() {
  cd $APP_DIR
  yarn install
}

function createCache() {
  cp -R $GLOBAL_CACHE_PATH/* $USER_CACHE_PATH/
}

createFolders
installPackages
createCache
