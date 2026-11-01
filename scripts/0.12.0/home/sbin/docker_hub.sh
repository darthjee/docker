#!/bin/bash

function fetch_docker_hub_token() {
  curl -s https://hub.docker.com/v2/users/login/ \
    -H "Content-Type: application/json" \
    -d '{"username":"'"$DOCKER_HUB_USERNAME"'","password":"'"$DOCKER_HUB_PASSWORD"'"}' \
  | jq -r .token
}

function run_login() {
  export DOCKER_HUB_TOKEN=$(fetch_docker_hub_token)
}

function run_push_description() {
  DOCKERHUB_REPOSITORY="$1"
  CONTENT=""
  while IFS= read -r LINE; do
    LINE=$(echo "$LINE" | sed 's/\\/\\\\/g')
    LINE=$(echo "$LINE" | sed 's/"/\\"/g')
    CONTENT="${CONTENT}${LINE}\\n"
  done < "$2"

  curl -X PATCH "https://hub.docker.com/v2/repositories/$DOCKERHUB_REPOSITORY" \
    -H "Authorization: JWT ${DOCKER_HUB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{ "full_description": "'"$CONTENT"'" }'
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
  "login_and_push_description")
    run_login
    run_push_description "$1" "$2"
    ;;
  "push")
    run_push "$1"
    ;;
esac
