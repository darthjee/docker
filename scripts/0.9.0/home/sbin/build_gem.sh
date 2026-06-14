#!/bin/bash

function version_path() {
  PROJECT_PATH=$(echo "$PROJECT" | tr '-' '/')
  echo "lib/$PROJECT_PATH/version.rb"
}

function version() {
  grep VERSION "$(version_path)" | sed -e "s/.*'\\(.*\\)'.*/\\1/g"
}

function is_tagged() {
  VERSION=$(version)
  TAG=$(git describe --abbrev=0 --tags)

  if [ "$VERSION" = "$TAG" ]; then
    return 0
  else
    echo "Gem Version: $VERSION"
    echo "Git tag:     $TAG"
    return 1
  fi
}

function is_latest_commit() {
  VERSION=$(version)
  DIFF=$(git diff HEAD "$VERSION")

  if [[ "$DIFF" ]]; then
    return 1
  else
    return 0
  fi
}

function is_latest_tag_and_commit() {
  if ( is_tagged && is_latest_commit ); then
    return 0
  else
    return 1
  fi
}

ACTION=$1

case $ACTION in
  "signin")
    mkdir ~/.gem
    echo "---" > ~/.gem/credentials
    echo ":rubygems_api_key: $RUBY_GEMS_API_KEY" >> ~/.gem/credentials
    chmod 600 ~/.gem/credentials
    ;;
  "build")
    if $(is_latest_tag_and_commit); then
      rake build
    else
      echo version did not change
    fi
    ;;
  "push")
    if $(is_latest_tag_and_commit); then
      VERSION=$(version)
      gem push "pkg/$PROJECT-$VERSION.gem"
    else
      echo version did not change
    fi
    ;;
  *)
    echo Usage:
    echo "$0 build # builds gem"
    echo "$0 push # pushes gem"
    ;;
esac
