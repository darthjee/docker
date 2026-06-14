#!/bin/bash

function release_image() {
  IMAGE=$1
  if [ -d $IMAGE ]; then
    bin/image.sh push $IMAGE
  else
    echo skipping $IMAGE
  fi
}

function release_images() {
  PROJECT=$1
  for MOD in "" circleci_ production_; do
    release_image $MOD$PROJECT
  done
}

function release() {
  shift 1

  if [ $1 ]; then
    for PROJECT in $*; do
      release_images $PROJECT
    done
  else
    help
  fi
}
