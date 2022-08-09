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

ACTION=$1

case $ACTION in
  "check")
    check_bundle
    ;;
  *)
    echo "Usage:"
    echo "$0 check # checks if gems have been installed"
    ;;
esac
