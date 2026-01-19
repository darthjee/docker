#!/bin/bash

function run_login() {
    echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
}

function run_push() {
    docker push $*
}

ACTION="$1"

shift 1

case "$ACTION" in
  "login")
    run_login
    ;;
  "push")
    run_push
    ;;
esac