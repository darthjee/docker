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

function replace_base_image() {
  BASE=${DOCKER_IMAGE%:*}
  TARGET=$MOD$IMAGE/$VERSION/Dockerfile
  sed -e "s/$BASE:[^ ]*/$DOCKER_IMAGE/g" -i $TARGET
}

function copy_base_image() {
  DOCKER_IMAGE=$(grep "FROM .*:" $IMAGE/$VERSION/Dockerfile | sed -e "s/FROM //g" | sed -e 's/.*\///g' | sed -e "s/ .*//g")

  for DOCKER_IMAGE in $DOCKER_IMAGE; do
    replace_base_image $DOCKER_IMAGE
  done
}

function copy_deps() {
  IMAGE=$2

  if [ $IMAGE ]; then
    VERSION=$(current_version $IMAGE)

    for MOD in circleci_ production_; do
      copy_home $MOD$IMAGE $VERSION
      copy_base_image $MOD$IMAGE $VERSION
    done

  else
    help
  fi
}
