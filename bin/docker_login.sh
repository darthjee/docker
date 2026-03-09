#!/bin/bash

function docker_login() {
  if [ -z "${DOCKER_HUB_USERNAME:-}" ]; then
    echo "Error: DOCKER_HUB_USERNAME is not set"
    exit 1
  fi

  if [ -z "${DOCKER_HUB_PASSWORD:-}" ]; then
    echo "Error: DOCKER_HUB_PASSWORD is not set"
    exit 1
  fi

  export DOCKER_HUB_TOKEN=$(curl -s https://hub.docker.com/v2/users/login/ \
    -H "Content-Type: application/json" \
    -d '{"username":"'"$DOCKER_HUB_USERNAME"'","password":"'"$DOCKER_HUB_PASSWORD"'"}' \
    | jq -r .token)
}
