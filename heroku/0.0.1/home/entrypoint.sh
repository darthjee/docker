#!/bin/sh

mkdir -p $HOME/.local/share/heroku
cp $HOME/config/config.json $HOME/.local/share/heroku/
cp $HOME/config/.netrc $HOME

#heroku $*
/bin/sh
