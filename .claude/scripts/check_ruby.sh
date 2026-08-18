#!/usr/bin/env bash
set -euo pipefail
set -x

for image in ruby_331 rails_gems circleci_ruby_331 circleci_rails_gems production_ruby_331; do
  bin/script.sh pre_build "$image"
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
