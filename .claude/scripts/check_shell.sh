#!/usr/bin/env bash
set -euo pipefail
set -x

export DOCKER_ID_USER="${DOCKER_ID_USER:-darthjee}"

bin/script.sh build scripts
bin/script.sh test scripts
