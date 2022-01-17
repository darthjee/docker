#!/bin/bash

ARGS=$(echo $* | xargs)

mkdir -p $HOME_DIR/.cache/bower 
/bin/cp $HOME_DIR/.cache/bower $HOME_DIR/bower_cache -R
mkdir -p $HOME_DIR/bower/registry/registry.bower.io/lookup/
mkdir -p $HOME_DIR/bower/packages/

bower install $ARGS

for PATH in $(/usr/bin/find $HOME_DIR/.cache/bower/registry/registry.bower.io/lookup/ -type f); do
  SOURCE=$HOME_DIR/.cache/bower/registry/registry.bower.io/lookup/
  DEST=$HOME_DIR/bower/registry/registry.bower.io/lookup/
  PACKAGE=${PATH##$SOURCE}

  if [ ! -x $DEST/$PACKAGE ]; then
    /bin/cp $PATH $DEST -R
  fi
done

for PATH in $HOME_DIR/.cache/bower/packages/*/*; do
  SOURCE=$HOME_DIR/.cache/bower/packages/
  PAKAGE_FULL_PATH=${PATH##$SOURCE}
  DEST=$HOME_DIR/bower/packages/

  PACKAGE=${PAKAGE_FULL_PATH%%/*}
  VERSION=${PAKAGE_FULL_PATH##*/}

  if [ ! -x $DEST/$PACKAGE/$VERSION ]; then
    mkdir -p $DEST/$PACKAGE
    /bin/cp $PATH $DEST/$PACKAGE -R
  fi
done
