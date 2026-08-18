#!/usr/bin/env bash
set -euo pipefail
set -x

for image in ruby_node rails_bower rails_yarn taa taap \
             circleci_ruby_node circleci_rails_bower circleci_rails_yarn circleci_taa circleci_taap \
             production_ruby_node production_rails_bower production_rails_yarn production_taa production_taap; do
  bin/script.sh pre_build "$image"
  bin/script.sh build "$image"
  bin/script.sh test "$image"
done
