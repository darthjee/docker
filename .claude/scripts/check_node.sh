#!/usr/bin/env bash
set -euo pipefail
set -x

export DOCKER_ID_USER="${DOCKER_ID_USER:-darthjee}"

for image in node node_mongo; do
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
