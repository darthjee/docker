#!/bin/bash

SCRIPT_FOLDER=.dt-heroku
SCRIPT_PATH=$HOME/$SCRIPT_FOLDER
ACTION=$1
BASH_FILE=$HOME/.bashrc

if [ ! $ACTION ]; then
  if (! grep $SCRIPT_FOLDER $BASH_FILE > /dev/null); then
    echo "eval \$(\$HOME/$SCRIPT_FOLDER/heroku install -)" >> $BASH_FILE
    eval $($SCRIPT_PATH/heroku install -)
  fi
fi
