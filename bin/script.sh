#!/bin/bash

source 'bin/build.sh'
source 'bin/release.sh'
source 'bin/init.sh'
source 'bin/copy_deps.sh'

function help() {
    echo Usage:
    echo "$0 init <image> [new_version] # inits a new version"
    echo "$0 copy_deps <image> # copy dependencies files"
    echo "$0 build <images> # build set of images"
    echo "$0 release <images> # release set of images"
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
  "release")
    release $*
    ;;
  *)
    help
    ;;
esac
