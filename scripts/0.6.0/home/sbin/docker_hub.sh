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

function run_push_description() {
    DOCKERHUB_REPOSITORY="$1"
    CONTENT=$(sed -e "s/^/\\\n/g" "$2")
    CONTENT=$(echo $CONTENT | sed -e "s/\\\\$/\\\\\\\\/g")
    CONTENT=$(echo $CONTENT | sed -e "s/\\\\ /\\\\\\\\ /g")
    CONTENT=$(echo $CONTENT | sed -e 's/"/\\"/g')
    echo $CONTENT;
    echo ""
    CONTENT=$(echo $CONTENT)

    set -x
    curl -X PATCH "https://hub.docker.com/v2/repositories/$DOCKERHUB_REPOSITORY" \
      -H "Authorization: JWT ${DOCKER_HUB_TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{ "full_description": "'"$CONTENT"'" }'
    set +x
}

function run_push() {
    docker push "$1"
}

ACTION="$1"

shift 1

case "$ACTION" in
  "login")
    run_login
    ;;
  "push_description")
    run_push_description "$1" "$2"
    ;;
  "push")
    run_push "$1"
    ;;
esac
