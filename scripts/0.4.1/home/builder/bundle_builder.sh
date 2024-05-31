#!/bin/bash

ARGS=$(echo $* | xargs)

if [ ! $BUNDLE_FOLDER ]; then
  BUNDLE_FOLDER=/usr/local/bundle
fi

cp $BUNDLE_FOLDER $HOME_DIR/bundle_cache -R
mkdir -p $HOME_DIR/bundle/gems/
mkdir -p $HOME_DIR/bundle/cache/
mkdir -p $HOME_DIR/bundle/specifications/
mkdir -p $HOME_DIR/bundle/bin/
mkdir -p $HOME_DIR/bundle/extensions/

bundle install $ARGS

for FILE_PATH in $BUNDLE_FOLDER/gems/*; do
  GEM=${FILE_PATH##$BUNDLE_FOLDER/gems/}
  if [ ! -x $HOME_DIR/bundle_cache/gems/$GEM ]; then
    cp $FILE_PATH $HOME_DIR/bundle/gems/$GEM -R
    cp $BUNDLE_FOLDER/cache/$GEM.gem $HOME_DIR/bundle/cache -R
    cp $BUNDLE_FOLDER/specifications/$GEM.gemspec $HOME_DIR/bundle/specifications -R
  fi
done

for FILE_PATH in $BUNDLE_FOLDER/bin/*; do
  BIN=${FILE_PATH##$BUNDLE_FOLDER/bin/}
  if [ ! -x $HOME_DIR/bundle_cache/bin/$BIN ]; then
    cp $FILE_PATH $HOME_DIR/bundle/bin/$BIN -R
  fi
done

for FILE_PATH in $(/usr/bin/find $BUNDLE_FOLDER/extensions/ -type f); do
  EXT_PATH=${FILE_PATH##$BUNDLE_FOLDER/extensions/}
  EXT_DIR=${EXT_PATH%/*}

  if [ ! -x $HOME_DIR/bundle_cache/extensions/$EXT_PATH ]; then
    mkdir -p $HOME_DIR/bundle/extensions/$EXT_DIR
    cp $FILE_PATH $HOME_DIR/bundle/extensions/$EXT_PATH -R
  fi
done
