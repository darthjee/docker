#!/bin/bash

SCRIPT_FOLDER=$HOME/.dt-heroku
ACTION=$1
BASH_FILE=$HOME/.bashrc

if [ ! $ACTION ]; then
  if (grep $SCRIPT_FOLDER $BASH_FILE); then
    echo not installing
  else
    echo installing
    echo "eval \$(\$HOME/$SCRIPT_FOLDER/heroku install -)" >> $BASH_FILE
  fi
fi
