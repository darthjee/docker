#!/bin/bash

source 'bin/build.sh'
source 'bin/release.sh'
source 'bin/test.sh'
source 'bin/init.sh'
source 'bin/copy_deps.sh'
source 'bin/update_deps.sh'
source 'bin/pre_build.sh'

function help() {
    echo Usage:
    echo "$0 init <image> [new_version] # inits a new version"
    echo "$0 copy_deps <image> # copy dependencies files"
    echo "$0 update_deps <image> <source> # copy dependencies from one image to another"
    echo "$0 build <images> # build set of images"
    echo "$0 release <images> # release set of images"
    echo "$0 test <images> # test an image"
    echo "$0 pre_build <images> # test an image before building"
}

ACTION=$1

case $ACTION in
  "init")
    init $*
    ;;
  "copy_deps")
    copy_deps $*
    ;;
  "update_deps")
    update_deps $*
    ;;
  "build")
    build $*
    ;;
  "release")
    release $*
    ;;
  "test")
    testy $*
    ;;
  "pre_build")
    pre_build $*
    ;;
  *)
    help
    ;;
esac
