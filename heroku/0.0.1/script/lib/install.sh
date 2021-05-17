#!/bin/bash

CMD=$0
CMD_FOLDER=$(echo $CMD | sed -e "s/\\/lib\\/[^\\/]*$//g")
SCRIPT_FOLDER=.dt-heroku
SCRIPT_PATH=$HOME/$SCRIPT_FOLDER
ACTION=$1
BASH_FILE=$HOME/.bashrc

if [ ! $ACTION ]; then
  cp -R $CMD_FOLDER/ $SCRIPT_PATH/

  if (! grep $SCRIPT_FOLDER $BASH_FILE > /dev/null); then
    echo "eval \"\$(\$HOME/$SCRIPT_FOLDER/heroku install -)\"" >> $BASH_FILE
    source ~/.bashrc
  fi

  exit 0
fi

echo "export PATH=\"\${PATH}:\${HOME}.dt-heroku/\""
