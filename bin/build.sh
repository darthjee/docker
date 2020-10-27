#!/bin/bash

function build_image() {
  IMAGE=$1
  if [ -d $IMAGE ]; then
    make IMAGES=$IMAGE build tag
  else
    echo skipping $IMAGE
  fi
}

function build_images() {
  PROJECT=$1
  for MOD in "" circleci_ production_; do
    build_image $MOD$PROJECT
  done
}

function build() {
  shift 1

  if [ $1 ]; then
    for PROJECT in $*; do
      build_images $PROJECT
    done
  else
    help
  fi
}
