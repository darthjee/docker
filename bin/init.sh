#!/bin/bash

source 'bin/build.sh'

function current_version() {
  IMAGE=$1
  echo $(cat version | grep "^"$IMAGE"=" | sed -e "s/"$IMAGE"=//g")
}

function version() {
  IMAGE=$1
  VERSION=$2

  if [ ! $VERSION ]; then
    VERSION=$(current_version $IMAGE)
    LAST=$(echo $VERSION | sed "s/.*\.//g")
    LAST=$[$LAST+1]
    VERSION=$(echo $VERSION | sed -e "s/\.[^.]*$/.$LAST/g")
  fi

  echo $VERSION
}

function copy() {
  IMAGE_NAME=$1
  CURRENT_VERSION=$2
  VERSION=$3

  if [ -d $IMAGE_NAME ]; then
    cp -R $IMAGE_NAME/$CURRENT_VERSION $IMAGE_NAME/$VERSION
  else
    echo skipping $IMAGE_NAME
  fi
}

function update_versions() {
  IMAGE_NAME=$1
  sed -e "s/^$IMAGE_NAME=.*/$IMAGE_NAME=$VERSION/g" version > aux
  mv aux version
}

function init() {
  IMAGE=$2

  if [ $IMAGE ]; then
    VERSION=$(version $IMAGE $3)
    CURRENT_VERSION=$(current_version $IMAGE)

    for MOD in "" circleci_ production_; do
      copy $MOD$IMAGE $CURRENT_VERSION $VERSION
      update_versions $MOD$IMAGE $CURRENT_VERSION $VERSION
    done
  else
    help
  fi
}
