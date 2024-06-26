#!/bin/bash

if [ ! $MODULES_FOLDER ]; then
  MODULES_FOLDER=/usr/lib/node_modules
fi

NEW_MODULES_DIR=$HOME_DIR/node_modules
APP_DIR=$HOME_DIR/app
APP_MODULES_DIR=$APP_DIR/node_modules

function createFolders() {
  mkdir -p $NEW_MODULES_DIR
  mkdir -p $APP_MODULES_DIR
}

function installPackages() {
  cd $APP_DIR; yarn install
}

function extractVersion() {
  cat $1/package.json | grep '^  "version' | sed -e 's/.*: *"//g' | sed -e 's/".*//g'
}

function isNewVersion() {
  echo $1
  OLD_VERSION=$(extractVersion $1)
  NEW_VERSION=$(extractVersion $2)

  if [ $OLD_VERSION = $NEW_VERSION ]; then
    return 1;
  else
    return 0;
  fi
}

function copyNewInstalled() {
  for FILE_PATH in $APP_MODULES_DIR/*; do
    PACKAGE=${FILE_PATH##$APP_MODULES_DIR/}
    ORIGIN_PATH_DIR=$MODULES_FOLDER/$PACKAGE
    NEW_PACKAGE_PATH=$NEW_MODULES_DIR/$PACKAGE

    if [ ! -x $ORIGIN_PATH_DIR ]; then
       cp -R $FILE_PATH $NEW_PACKAGE_PATH
    elif ( isNewVersion $FILE_PATH $ORIGIN_PATH_DIR ); then
       rm -rf $ORIGIN_PATH_DIR
       cp -R $FILE_PATH $NEW_PACKAGE_PATHH
    fi
  done
}

createFolders
installPackages
copyNewInstalled
