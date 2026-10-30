#!/usr/bin/env bash
set -euo pipefail
set -x

export DOCKER_ID_USER="${DOCKER_ID_USER:-darthjee}"

for image in ruby_node rails_bower rails_yarn taa taap; do
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
