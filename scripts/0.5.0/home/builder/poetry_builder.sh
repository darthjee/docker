#!/bin/bash

if [ ! $APP_DIR ]; then
  APP_DIR=$HOME_DIR/app
fi

GLOBAL_CACHE_PATH=/home/app/.cache/pypoetry
USER_CACHE_PATH=$HOME_DIR/poetry/cached
NEW_PACKAGES_PATH=$HOME_DIR/poetry/new

function createFolders() {
  mkdir -p $GLOBAL_CACHE_PATH
  mkdir -p $USER_CACHE_PATH
  mkdir -p $NEW_PACKAGES_PATH
}

function installPackages() {
  cd $APP_DIR
  poetry install --no-root --no-interaction --no-ansi
}

function copyNewPackages() {
  for PACKAGE_PATH in $GLOBAL_CACHE_PATH/*; do
    PACKAGE_NAME=${PACKAGE_PATH##$GLOBAL_CACHE_PATH/}
    
    if [ ! -d "$USER_CACHE_PATH/$PACKAGE_NAME" ]; then
      cp -R $PACKAGE_PATH $NEW_PACKAGES_PATH/
    fi
  done
}

function createCache() {
  cp -R $GLOBAL_CACHE_PATH/* $USER_CACHE_PATH/
}

createFolders
createCache
installPackages
copyNewPackages