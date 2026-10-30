#!/bin/bash

function test_image() {
  IMAGE=$1
  if [ -d $IMAGE ]; then
    bin/image.sh test $IMAGE
  else
    echo skipping $IMAGE
  fi
}

function test_images() {
  PROJECT=$1
  local status=0
  for MOD in "" circleci_ production_; do
    test_image $MOD$PROJECT || status=1
  done
  return $status
}

function testy() {
  shift 1

  if [ $1 ]; then
    local status=0
    for PROJECT in $*; do
      test_images $PROJECT || status=1
    done
    return $status
  else
    help
  fi
}
