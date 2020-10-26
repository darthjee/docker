#!/bin/bash

function current_version() {
  IMAGE=$1
  echo $(cat version | grep "^"$IMAGE"=" | sed -e "s/"$IMAGE"=//g")
}

function version() {
  IMAGE=$1
  VERSION=$2

  if [ ! $VERSION ]; then
    VERSION=$(current_version $IMAGE)
    LAST=$(echo $VERSION | sed "s/.*\.//g")
    LAST=$[$LAST+1]
    VERSION=$(echo $VERSION | sed -e "s/\.[^.]*$/.$LAST/g")
  fi

  echo $VERSION
}

function build() {
  IMAGE=$2

  if [ $IMAGE ]; then
    VERSION=$(version $IMAGE $3)
    CURRENT_VERSION=$(current_version $IMAGE)

    echo cp -R $IMAGE/$CURRENT_VERSION $IMAGE/$VERSION
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
