#!/bin/bash

function fetch_bases() {
  IMAGE=$1
  VERSION=$(cat version | grep "^"$IMAGE"=" | sed -e "s/"$IMAGE"=//g")

  BASES=$(cat $IMAGE/$VERSION/Dockerfile | grep FROM | grep darthjee | sed -e "s/.*darthjee/darthjee/g" | sed -e "s/:\([^ ]*\) .*/:\\1/g")

  for BASE in $BASES; do
    BUILDABLE=$(echo $BASE | sed -e "s/:.*//g" | sed -e "s/.*\\///g")
    if docker pull "$BASE"; then
      continue
    fi

    echo "Pull of $BASE failed, building $BUILDABLE locally"
    $0 build "$BUILDABLE" || return 1

    if ! docker image inspect "$BASE" >/dev/null 2>&1; then
      local built_version
      built_version=$(cat version | grep "^${BUILDABLE}=" | sed -e "s/${BUILDABLE}=//g")
      echo "ERROR: $BASE not available: pull failed and building $BUILDABLE produced $BUILDABLE:$built_version, not the pinned tag" >&2
      return 1
    fi
  done
}

function build_image() {
  IMAGE=$1
  if [ -d $IMAGE ]; then
    fetch_bases $IMAGE || return 1
    bin/image.sh build $IMAGE || return 1
  else
    echo skipping $IMAGE
  fi
}

function build_images() {
  PROJECT=$1
  for MOD in "" circleci_ production_; do
    build_image $MOD$PROJECT || return 1
  done
}

function build() {
  shift 1

  if [ $1 ]; then
    for PROJECT in $*; do
      build_images $PROJECT || return 1
    done
  else
    help
  fi
}
