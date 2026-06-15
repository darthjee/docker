#!/bin/bash

ARGS=("$@")

if [ ! "$APP_DIR" ]; then
  APP_DIR="$HOME_DIR"/app
fi

GLOBAL_CACHE_PATH=/usr/local/share/.cache/yarn/v6
USER_CACHE_PATH="$HOME_DIR"/yarn/cached
NEW_PACKAGES_PATH="$HOME_DIR"/yarn/new

function create_folders() {
  mkdir -p "$GLOBAL_CACHE_PATH"
  mkdir -p "$USER_CACHE_PATH"
  mkdir -p "$NEW_PACKAGES_PATH"
}

function install_packages() {
  cd "$APP_DIR"
  yarn install "${ARGS[@]}"
}

function copy_new_packages() {
  for PACKAGE_PATH in "$GLOBAL_CACHE_PATH"/*; do
    PACKAGE_NAME=${PACKAGE_PATH##"$GLOBAL_CACHE_PATH"/}

    if [ ! -d "$USER_CACHE_PATH/$PACKAGE_NAME" ]; then
      cp -R "$PACKAGE_PATH" "$NEW_PACKAGES_PATH"/
    fi
  done
}

function create_cache() {
  if compgen -G "$GLOBAL_CACHE_PATH/*" > /dev/null; then
    cp -R "$GLOBAL_CACHE_PATH"/* "$USER_CACHE_PATH"/
  fi
}

create_folders
create_cache
install_packages
copy_new_packages
