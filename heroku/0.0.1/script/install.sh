#!/bin/bash

SCRIPT_FOLDER=$HOME/.dt-heroku
ACTION=$1

if [ ! $ACTION ]; then
  echo "eval $$($$HOME/$SCRIPT_FOLDER/heroku install -)" >> $HOME/.bashrc
fi
