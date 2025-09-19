#!/bin/bash

if [ ! $CACHE_FOLDER ]; then
  CACHE_FOLDER=/usr/local/share/.cache/yarn
fi

if [ ! $APP_DIR ]; then
  APP_DIR=$HOME_DIR/app
fi

NEW_CACHE_DIR=$HOME_DIR/.cache/yarn
APP_MODULES_DIR=$APP_DIR/node_modules

function createFolders() {
  mkdir -p $NEW_CACHE_DIR
  mkdir -p $APP_MODULES_DIR
}

function installPackages() {
  cd $APP_DIR; yarn install
}

function copyCache() {
  if [ -d "$NEW_CACHE_DIR" ]; then
    cp -R $NEW_CACHE_DIR/* $CACHE_FOLDER/
  fi
}

createFolders
installPackages
copyCache
