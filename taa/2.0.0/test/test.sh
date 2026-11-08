#!/bin/bash

FAILED=0

for TEST in /home/test/subtests/*.sh; do
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
