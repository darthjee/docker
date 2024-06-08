#!/bin/bash

if [ ! $MODULES_FOLDER ]; then
  MODULES_FOLDER=/usr/lib/node_modules
fi

CACHE_DIR=$HOME_DIR/modules_cache
NEW_MODULES_DIR=$HOME_DIR/node_modules

function createFolders() {
  cp $MODULES_FOLDER $CACHE_DIR -R
  mkdir -p $NEW_MODULES_DIR
}

function installPackages() {
  SED='/[dD]ependencies": {/,/}/ {s/    "\([^"]*\)": *"\(.*\)",\?/\1@\2/gp}'
  echo $SED > /tmp/package_sed.sed
  npm install -g $(sed -f /tmp/package_sed.sed package.json -n)
}

createFolders
installPackages

for FILE_PATH in $MODULES_FOLDER/*; do
  PACKAGE=${FILE_PATH##$MODULES_FOLDER/}
  echo package $PACKAGE
  echo PATH $HOME_DIR/modules_cache/$PACKAGE
  if [ ! -x $HOME_DIR/modules_cache/$PACKAGE ]; then
    echo NEW PACKAGE $PACKAGE
  else
    echo OLD PACKAGE $PACKAGE
  fi
done
