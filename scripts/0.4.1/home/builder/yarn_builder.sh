#!/bin/bash

if [ ! $MODULES_FOLDER ]; then
  MODULES_FOLDER=/usr/lib/node_modules
fi

cp $MODULES_FOLDER $HOME_DIR/modules_cache -R
mkdir -p $HOME_DIR/node_modules

SED='/[dD]ependencies": {/,/}/ {s/    "\([^"]*\)": *"\(.*\)",\?/\1@\2/gp}'
echo $SED > /tmp/package_sed.sed
npm install -g $(sed -f /tmp/package_sed.sed package.json -n)

for FILE_PATH in $MODULES_FOLDER/*; do
  PACKAGE=${FILE_PATH##$MODULES_FOLDER/}
  echo package $PACKAGE
  echo PATH $HOME_DIR/modules_cache/$PACKAGE
  if [ ! -x $HOME_DIR/modules_cache/$PACKAGE ]; then
    echo NEW PACKAGE $PACKAGE
  fi
done
