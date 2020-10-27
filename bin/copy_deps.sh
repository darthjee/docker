#!/bin/bash

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
