#!/bin/bash

function push_description_image() {
  IMAGE=$1
  if [ -d "$IMAGE" ]; then
    VERSION=$(cat version | grep "^"$IMAGE"=" | sed -e "s/"$IMAGE"=//g")
    README="$IMAGE/$VERSION/README.md"
    if [ ! -f "$README" ]; then
      echo "Warning: README not found at $README, skipping."
      return 0
    fi
    REPO="darthjee/$IMAGE"
    if [ -z "${DOCKER_HUB_TOKEN:-}" ]; then
      docker_login
    fi
    CONTENT=""
    while IFS= read -r LINE; do
      LINE=$(echo "$LINE" | sed 's/\\/\\\\/g')
      LINE=$(echo "$LINE" | sed 's/"/\\"/g')
      CONTENT="${CONTENT}${LINE}\\n"
    done < "$README"
    RESPONSE=$(mktemp)
    HTTP_CODE=$(curl -sS -o "$RESPONSE" -w '%{http_code}' \
      -X PATCH "https://hub.docker.com/v2/repositories/$REPO/" \
      -H "Authorization: JWT ${DOCKER_HUB_TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{ "full_description": "'"$CONTENT"'" }')
    case "$HTTP_CODE" in
      2??)
        rm -f "$RESPONSE"
        echo "Pushed description for $REPO"
        ;;
      *)
        echo "Error: failed to push description for $REPO (HTTP $HTTP_CODE)"
        cat "$RESPONSE"
        echo
        rm -f "$RESPONSE"
        exit 1
        ;;
    esac
  else
    echo skipping $IMAGE
  fi
}

function push_description_images() {
  PROJECT=$1
  push_description_image $PROJECT
  for MOD in circleci_ production_; do
    push_description_image $MOD$PROJECT
  done
}

function push_description() {
  shift 1

  if [ $1 ]; then
    for PROJECT in $*; do
      push_description_images $PROJECT
    done
  else
    help
  fi
}
