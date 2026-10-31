#!/bin/bash

source 'bin/docker_login.sh'
source 'bin/push_description.sh'

PLATFORM=${PLATFORM:-linux/amd64}

function image_version() {
  local image=$1
  local matches count
  matches=$(grep "^${image}=" version)
  count=$(printf '%s' "$matches" | grep -c '^')

  if [ "$count" -eq 0 ]; then
    echo "ERROR: no entry for ${image} in version" >&2
    return 1
  fi

  if [ "$count" -gt 1 ]; then
    echo "ERROR: ${image} has ${count} entries in version" >&2
    return 1
  fi

  echo "${matches#"${image}="}"
}

function skip_if_unchanged() {
  local image=$1
  shift
  local pathspecs=("$@")
  local version
  version=$(image_version "$image") || exit 1

  local prev_tag
  prev_tag=$(git tag --sort=-creatordate | awk 'NR==2{print; exit}')

  if [ -z "$prev_tag" ]; then
    echo "No previous tag found, proceeding with release of $image."
    return 0
  fi

  if git diff --quiet "$prev_tag"..HEAD -- "$image/$version/" "${pathspecs[@]}"; then
    if [ ${#pathspecs[@]} -gt 0 ]; then
      echo "No changes in $image/$version/ (excluding ${pathspecs[*]}) since $prev_tag, skipping."
    else
      echo "No changes in $image/$version/ since $prev_tag, skipping."
    fi
    exit 0
  fi
}

function build() {
  local image=$1
  local arch=$2
  local version
  version=$(image_version "$image") || exit 1

  local platform tag_suffix
  if [ -n "$arch" ]; then
    platform="linux/$arch"
    tag_suffix="-$arch"
  else
    platform="$PLATFORM"
    tag_suffix=""
  fi

  local latest_tag="$DOCKER_ID_USER/$image:latest${tag_suffix}"
  local cached_tag="$DOCKER_ID_USER/$image:cached${tag_suffix}"
  local version_tag="$DOCKER_ID_USER/$image:${version}${tag_suffix}"

  docker tag "$latest_tag" "$cached_tag" 2>/dev/null || true
  docker rmi "$latest_tag" 2>/dev/null || true
  docker build --platform "$platform" \
    -f "$image/$version/Dockerfile" "$image/$version/" \
    -t "$latest_tag" || return 1
  docker tag "$latest_tag" "$version_tag" || return 1
  if docker images | grep -q "$cached_tag"; then
    docker rmi "$cached_tag"
  fi
}

function tag() {
  build "$1" "$2"
}

function push() {
  local image=$1
  local version
  version=$(image_version "$image") || exit 1

  skip_if_unchanged "$image" \
    ":(exclude)$image/$version/README.md" \
    ":(exclude)$image/$version/test/"

  echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin

  docker buildx build --platform linux/amd64,linux/arm64 \
    -f "$image/$version/Dockerfile" "$image/$version/" \
    -t "$DOCKER_ID_USER/$image:$version" \
    -t "$DOCKER_ID_USER/$image:latest" \
    --push
}

function description() {
  local image=$1

  skip_if_unchanged "$image"

  push_description_image "$image"
}

function image_test() {
  local image=$1
  local version
  version=$(image_version "$image") || exit 1
  local user_name=${image%%_*}
  user_name=$(echo "$user_name" | grep circleci || echo app)

  if [ ! -d "$image/$version/test" ]; then
    echo "no tests for $image"
    return 0
  fi

  local test_dockerfile="$image/$version/test/Dockerfile"
  if [ ! -f "$test_dockerfile" ]; then
    test_dockerfile="Dockerfile.test"
  fi

  DOCKER_ID_USER="$DOCKER_ID_USER" IMAGE="$image" VERSION="$version" \
    USER_NAME="$user_name" TEST_DOCKERFILE="$test_dockerfile" \
    DOCKER_DEFAULT_PLATFORM="$PLATFORM" \
    IMAGE_NAME="${image}_test" docker-compose build test || return 1

  DOCKER_ID_USER="$DOCKER_ID_USER" IMAGE="$image" VERSION="$version" \
    USER_NAME="$user_name" TEST_DOCKERFILE="$test_dockerfile" \
    DOCKER_DEFAULT_PLATFORM="$PLATFORM" \
    IMAGE_NAME="${image}_test" docker-compose run --rm test
}

ACTION=$1
IMAGE_NAME=$2
ARCH=${3:-}

case $ACTION in
  "build") build "$IMAGE_NAME" "$ARCH" || exit 1 ;;
  "tag")   tag "$IMAGE_NAME" "$ARCH" || exit 1 ;;
  "push")  push "$IMAGE_NAME" ;;
  "test")  image_test "$IMAGE_NAME" || exit 1 ;;
  "description") description "$IMAGE_NAME" ;;
  *)
    echo "Usage: $0 <action> <image_name> [arch]"
    echo "Actions: build, tag, push, test, description"
    echo "  arch applies to build/tag only (local single-platform debug builds)."
    exit 1
    ;;
esac
