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
  if [ ! -x $HOME_DIR/node_modules/$PACKAGE ]; then
    cp $FILE_PATH $HOME_DIR/bundle/gems/$GEM -R
    cp $MODULES_FOLDER/cache/$GEM.gem $HOME_DIR/bundle/cache -R
    cp $MODULES_FOLDER/specifications/$GEM.gemspec $HOME_DIR/bundle/specifications -R
  fi
done
