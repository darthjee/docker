#!/bin/sh

mkdir -p $HOME/.local/share/heroku

if [ -f $HOME/config/config.json ]; then
  if [ -f $HOME/config/.netrc ]; then
    cp $HOME/config/config.json $HOME/.local/share/heroku/
    cp $HOME/config/.netrc $HOME
  fi
fi

#heroku $*
/bin/sh
