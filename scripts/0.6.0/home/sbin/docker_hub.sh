#!/bin/bash

function fetchDockerHubToken() {
    curl -s https://hub.docker.com/v2/users/login/ \
        -H "Content-Type: application/json" \
        -d '{"username":"'"$DOCKER_HUB_USERNAME"'","password":"'"$DOCKER_HUB_PASSWORD"'"}' \
    | jq -r .token
}

function run_login() {
    echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin
    export DOCKER_HUB_TOKEN=$(fetchDockerHubToken)
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
    run_push $*
    ;;
esac