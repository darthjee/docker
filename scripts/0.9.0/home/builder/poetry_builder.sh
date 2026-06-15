#!/bin/bash

ARGS=$(echo "$*" | xargs)

if [ ! "$APP_DIR" ]; then
  APP_DIR="$HOME_DIR"/app
fi

GLOBAL_CACHE_PATH="$HOME_DIR"/.cache/pypoetry/artifacts
USER_CACHE_PATH="$HOME_DIR"/poetry/cached
NEW_PACKAGES_PATH="$HOME_DIR"/poetry/new

function create_folders() {
  mkdir -p "$GLOBAL_CACHE_PATH"
  mkdir -p "$USER_CACHE_PATH"
  mkdir -p "$NEW_PACKAGES_PATH"
}

function install_packages() {
  cd "$APP_DIR"
  poetry install --no-root --no-interaction --no-ansi "$ARGS"
}

function copy_new_packages() {
  for PACKAGE_FILE in "$GLOBAL_CACHE_PATH"/*/*/*/*/*; do
    if [ -f "$PACKAGE_FILE" ]; then
      RELATIVE_PATH=${PACKAGE_FILE##"$GLOBAL_CACHE_PATH"/}
      PACKAGE_DIR=${RELATIVE_PATH%/*}

      if [ ! -f "$USER_CACHE_PATH/$RELATIVE_PATH" ]; then
        mkdir -p "$NEW_PACKAGES_PATH/$PACKAGE_DIR"
        cp "$PACKAGE_FILE" "$NEW_PACKAGES_PATH/$RELATIVE_PATH"
      fi
    fi
  done
}

function create_cache() {
  if [ -d "$GLOBAL_CACHE_PATH" ] && [ "$(ls -A "$GLOBAL_CACHE_PATH" 2>/dev/null)" ]; then
    cp -R "$GLOBAL_CACHE_PATH"/* "$USER_CACHE_PATH"/
  fi
}

create_folders
create_cache
install_packages
copy_new_packages
