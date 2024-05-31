#!/bin/bash

ARGS=$(echo $* | xargs)

mkdir -p $HOME_DIR/.cache/bower 
cp $HOME_DIR/.cache/bower $HOME_DIR/bower_cache -R
mkdir -p $HOME_DIR/bower/registry/registry.bower.io/lookup/
mkdir -p $HOME_DIR/bower/packages/

bower install $ARGS

for FILE_PATH in $(/usr/bin/find $HOME_DIR/.cache/bower/registry/registry.bower.io/lookup/ -type f); do
  SOURCE=$HOME_DIR/.cache/bower/registry/registry.bower.io/lookup/
  DEST=$HOME_DIR/bower/registry/registry.bower.io/lookup/
  PACKAGE=${FILE_PATH##$SOURCE}

  if [ ! -x $DEST/$PACKAGE ]; then
    cp $FILE_PATH $DEST -R
  fi
done

for FILE_PATH in $HOME_DIR/.cache/bower/packages/*/*; do
  SOURCE=$HOME_DIR/.cache/bower/packages/
  PAKAGE_FULL_PATH=${FILE_PATH##$SOURCE}
  DEST=$HOME_DIR/bower/packages/

  PACKAGE=${PAKAGE_FULL_PATH%%/*}
  VERSION=${PAKAGE_FULL_PATH##*/}

  if [ ! -x $DEST/$PACKAGE/$VERSION ]; then
    mkdir -p $DEST/$PACKAGE
    cp $FILE_PATH $DEST/$PACKAGE -R
  fi
done
