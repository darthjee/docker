#!/bin/bash

source 'bin/build.sh'
source 'bin/init.sh'

function copy_home() {
  IMAGE_NAME=$1
  VERSION=$2

  if [ -d $IMAGE_NAME ]; then
    cp -R $IMAGE/$VERSION/home/* $IMAGE_NAME/$VERSION/home/
  else
    echo skipping $IMAGE_NAME
  fi
}

function copy_deps() {
  IMAGE=$2

  if [ $IMAGE ]; then
    VERSION=$(current_version $IMAGE)

    for MOD in circleci_ production_; do
      copy_home $MOD$IMAGE $VERSION
    done

  else
    help
  fi
}

function help() {
    echo Usage:
    echo "$0 init <image> [new_version] # inits a new version"
    echo "$0 copy_deps <image> # copy dependencies files"
    echo "$0 build <images> # copy dependencies files"
}

ACTION=$1

case $ACTION in
  "init")
    init $*
    ;;
  "copy_deps")
    copy_deps $*
    ;;
  "build")
    build $*
    ;;
  *)
    help
    ;;
esac
