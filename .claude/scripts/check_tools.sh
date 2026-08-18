#!/usr/bin/env bash
set -euo pipefail
set -x

for image in fly heroku; do
  bin/script.sh pre_build "$image"
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
