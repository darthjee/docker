#!/usr/bin/env bash
set -euo pipefail
set -x

for image in node node_mongo circleci_node circleci_node_mongo; do
  bin/script.sh pre_build "$image"
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
