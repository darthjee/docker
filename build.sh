#!/bin/bash

function version() {
  IMAGE=$1
  VERSION=$2

  if [ ! $VERSION ]; then
    VERSION=$(cat version | grep "^"$IMAGE"=" | sed -e "s/"$IMAGE"=//g")
  fi

  echo $VERSION
}

function build() {
  IMAGE=$2

  if [ $IMAGE ]; then
    VERSION=$(version $IMAGE $3)
    echo $VERSION
  else
    help
  fi
}

function copy_gems() {
  1
}

function help() {
    echo Usage:
    echo "$0 build # builds a new version"
    echo "$0 copy_deps # copy dependencies files"
}

ACTION=$1

case $ACTION in
  "build")
    build $*
    ;;
  "copy_deps")
    copy_gems
    ;;
  *)
    help
    ;;
esac
