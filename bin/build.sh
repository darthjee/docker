#!/bin/bash

function current_version() {
  IMAGE=$1
}

function fetch_bases() {
  IMAGE=$1
  VERSION=$(cat version | grep "^"$IMAGE"=" | sed -e "s/"$IMAGE"=//g")

  BASES=$(cat $IMAGE/$VERSION/Dockerfile | grep FROM | grep darthjee | sed -e "s/.*darthjee/darthjee/g" | sed -e "s/:\([^ ]*\) .*/:\\1/g")

  for BASE in $BASES; do
    BUILDABLE=$(echo $BASE | sed -e "s/:.*//g" | sed -e "s/.*\\///g")
    docker pull $BASE || $0 build $BUILDABLE
  done
}

function build_image() {
  IMAGE=$1
  if [ -d $IMAGE ]; then
    fetch_bases $IMAGE
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
