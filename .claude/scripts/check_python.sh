#!/usr/bin/env bash
set -euo pipefail
set -x

export DOCKER_ID_USER="${DOCKER_ID_USER:-darthjee}"

for image in python_37 django; do
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
