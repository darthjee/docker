#!/bin/bash

function test_image() {
  IMAGE=$1
  if [ -d $IMAGE ]; then
    make IMAGES=$IMAGE test
  else
    echo skipping $IMAGE
  fi
}

function test_images() {
  PROJECT=$1
  for MOD in "" circleci_ production_; do
    test_image $MOD$PROJECT
  done
}

function testy() {
  shift 1

  if [ $1 ]; then
    for PROJECT in $*; do
      test_images $PROJECT
    done
  else
    help
  fi
}
