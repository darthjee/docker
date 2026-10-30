#!/bin/bash

TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
FAILED=0

for TEST in "$TEST_DIR"/subtests/*.sh; do
  echo "== $(basename "$TEST")"
  if ! /bin/bash "$TEST"; then
    FAILED=$((FAILED + 1))
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "$FAILED test file(s) failed"
  exit 1
fi

echo "All tests passed"
