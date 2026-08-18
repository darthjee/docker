#!/usr/bin/env bash
set -euo pipefail
set -x

bin/script.sh pre_build scripts
bin/script.sh build scripts
bin/script.sh test scripts
