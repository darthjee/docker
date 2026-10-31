#!/bin/bash

EXPECTED_CACHE_DIR=/home/circleci/.cache/yarn/v6

# angular comes from circleci_taa, js-cookie from circleci_rails_yarn
PACKAGES="angular js-cookie"

CACHE_DIR=$(yarn cache dir)

if [ "$CACHE_DIR" != "$EXPECTED_CACHE_DIR" ]; then
  echo "expected yarn cache dir to be $EXPECTED_CACHE_DIR, got $CACHE_DIR"
  exit 1
fi

if ! compgen -G "$CACHE_DIR/npm-*" > /dev/null; then
  echo "yarn cache at $CACHE_DIR is empty"
  exit 1
fi

CACHED=$(ls "$CACHE_DIR")
FAILED=0

for PACKAGE in $PACKAGES; do
  if ! echo "$CACHED" | grep -q "^npm-$PACKAGE-[0-9]"; then
    echo "package $PACKAGE not found in yarn cache"
    FAILED=1
  fi
done

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi
