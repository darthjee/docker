#!/bin/sh

mkdir -p $HOME/.local/share/heroku

if [ -f $HOME/config/config.json ] && [ -f $HOME/config/.netrc ]; then
  cp $HOME/config/config.json $HOME/.local/share/heroku/
  cp $HOME/config/.netrc $HOME
fi

ACTION=$1
shift 1

if [ -f $HOME/scripts/$ACTION.sh ]; then
  $HOME/scripts/$ACTION.sh $*
elif (echo $ACTION | grep "^\\/"); then
  $ACTION $*
else
  heroku $ACTION $*
fi
