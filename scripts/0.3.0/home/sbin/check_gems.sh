#!/bin/bash

function missing_gems() {
  bundle check 2>&1 | grep " (" | sed -e "s/ *\* *\(.*\) (\(.*\))/\1:\2/g"
}

function check_bundle() {
  LIST=$(missing_gems)

  if [[ $LIST ]]; then
    exit 1
  else
    exit 0
  fi
}

function upgrade_all() {
  LIST=$(missing_gems)

  for MATCH in $LIST; do
    NAME=${MATCH%%:*}
    VERSION=${MATCH##*:}
    NEW_VERSION=$(latest_version $NAME)

    if [[ $NEW_VERSION ]]; then
      sed -e "s/gem ['\"]$NAME['\"] *$/gem '$NAME', '$NEW_VERSION'/g" -i Gemfile
    else
      echo "$NAME -- $VERSION -- |$NEW_VERSION|"
    fi
  done
}

function latest_version() {
  NAME=$1
  LINE=$(gem list | grep "^$NAME ")

  if [[ $LINE ]]; then
    echo $LINE | sed -e "s/.* (//g" | sed -e "s/) *//g" | sed -e "s/,//g" | sed -e "s/ /\\n/g" | head -n 1
  fi
}

ACTION=$1

case $ACTION in
  "check")
    check_bundle
    ;;
  "upgrade")
    upgrade_all
    ;;
  *)
    echo "Usage:"
    echo "$0 check # checks if gems have been installed"
    echo "$0 upgrade gems from gemfile when they are outdated # checks if gems have been installed"
    ;;
esac
