#!/bin/bash

ARGS=$(echo $* | xargs)

if [ ! $APP_DIR ]; then
  APP_DIR=$HOME_DIR/app
fi

GLOBAL_CACHE_PATH=/home/app/.cache/pypoetry/artifacts
USER_CACHE_PATH=$HOME_DIR/poetry/cached
NEW_PACKAGES_PATH=$HOME_DIR/poetry/new

function createFolders() {
  mkdir -p $GLOBAL_CACHE_PATH
  mkdir -p $USER_CACHE_PATH
  mkdir -p $NEW_PACKAGES_PATH
}

function installPackages() {
  cd $APP_DIR
  poetry install --no-root --no-interaction --no-ansi $ARGS
}

function copyNewPackages() {
  for PACKAGE_FILE in $GLOBAL_CACHE_PATH/*/*/*/*/*; do
    if [ -f "$PACKAGE_FILE" ]; then
      # Extract the relative path of the file
      RELATIVE_PATH=${PACKAGE_FILE##$GLOBAL_CACHE_PATH/}
      # Extract the directory of the file (folder structure)
      PACKAGE_DIR=${RELATIVE_PATH%/*}
      
      # Check if the file doesn't exist in user cache
      if [ ! -f "$USER_CACHE_PATH/$RELATIVE_PATH" ]; then
        # Create the directory structure in NEW_PACKAGES_PATH
        mkdir -p "$NEW_PACKAGES_PATH/$PACKAGE_DIR"
        # Copy the file maintaining the structure
        cp "$PACKAGE_FILE" "$NEW_PACKAGES_PATH/$RELATIVE_PATH"
      fi
    fi
  done
}

function createCache() {
  if [ -d "$GLOBAL_CACHE_PATH" ] && [ "$(ls -A $GLOBAL_CACHE_PATH 2>/dev/null)" ]; then
    cp -R $GLOBAL_CACHE_PATH/* $USER_CACHE_PATH/
  fi
}

createFolders
createCache
installPackages
copyNewPackages