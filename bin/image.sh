#!/bin/bash

PLATFORM=${PLATFORM:-linux/arm64/v8}

function image_version() {
  local image=$1
  cat version | grep "^${image}=" | sed -e "s/${image}=//g"
}

function build() {
  local image=$1
  local version
  version=$(image_version "$image")

  docker tag "$DOCKER_ID_USER/$image:latest" "$DOCKER_ID_USER/$image:cached" 2>/dev/null || true
  docker rmi "$DOCKER_ID_USER/$image:latest" 2>/dev/null || true
  docker build --platform "$PLATFORM" \
    -f "$image/$version/Dockerfile" "$image/$version/" \
    -t "$DOCKER_ID_USER/$image"
  docker tag "$DOCKER_ID_USER/$image" "$DOCKER_ID_USER/$image:$version"
  if docker images | grep -q "$DOCKER_ID_USER/$image.*cached"; then
    docker rmi "$DOCKER_ID_USER/$image:cached"
  fi
}

function tag() {
  build "$1"
}

function push() {
  local image=$1
  local version
  version=$(image_version "$image")

  build "$image"
  docker push "$DOCKER_ID_USER/$image"
  docker push "$DOCKER_ID_USER/$image:$version"
}

function image_test() {
  local image=$1
  local version
  version=$(image_version "$image")
  local user_name=${image%%_*}
  user_name=$(echo "$user_name" | grep circleci || echo app)

  DOCKER_ID_USER="$DOCKER_ID_USER" IMAGE="$image" VERSION="$version" \
    USER_NAME="$user_name" \
    IMAGE_NAME="${image}_test" docker-compose build test

  DOCKER_ID_USER="$DOCKER_ID_USER" IMAGE="$image" VERSION="$version" \
    USER_NAME="$user_name" \
    IMAGE_NAME="${image}_test" docker-compose run test pwd
}

ACTION=$1
IMAGE_NAME=$2

case $ACTION in
  "build") build "$IMAGE_NAME" ;;
  "tag")   tag "$IMAGE_NAME" ;;
  "push")  push "$IMAGE_NAME" ;;
  "test")  image_test "$IMAGE_NAME" ;;
  *)
    echo "Usage: $0 <action> <image_name>"
    echo "Actions: build, tag, push, test"
    exit 1
    ;;
esac
