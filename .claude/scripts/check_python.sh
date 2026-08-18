#!/usr/bin/env bash
set -euo pipefail
set -x

for image in python_37 django circleci_python_37 circleci_django production_django; do
  bin/script.sh pre_build "$image"
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
