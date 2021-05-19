#!/bin/sh

mkdir -p $HOME/.local/share/heroku

function has_configs() {
  for FILE in $HOME/config/config.json  $HOME/config/.netrc; do
    if [ ! -f $FILE ]; then
      return 1
    fi
  done
  return 0
}

if ( has_configs ); then
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
