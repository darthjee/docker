#!/bin/bash

EXPECTED_CACHE_DIR=/home/circleci/.cache/yarn/v6
PACKAGE_JSON=/home/circleci/project/package.json

CACHE_DIR=$(yarn cache dir)

if [ "$CACHE_DIR" != "$EXPECTED_CACHE_DIR" ]; then
  echo "expected yarn cache dir to be $EXPECTED_CACHE_DIR, got $CACHE_DIR"
  exit 1
fi

if ! compgen -G "$CACHE_DIR/npm-*" > /dev/null; then
  echo "yarn cache at $CACHE_DIR is empty"
  exit 1
fi

# Inherited from circleci_rails_yarn: makes sure this image's cache was merged
# into the base cache instead of replacing it
INHERITED_PACKAGE=js-cookie

if ! compgen -G "$CACHE_DIR/npm-$INHERITED_PACKAGE-[0-9]*" > /dev/null; then
  echo "inherited package $INHERITED_PACKAGE not found in yarn cache"
  exit 1
fi

PACKAGES=$(node -e '
  const pkg = require(process.argv[1]);
  const names = Object.keys(Object.assign({}, pkg.dependencies, pkg.devDependencies));
  console.log(names.join("\n"));
' "$PACKAGE_JSON")

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

TMP_PROJECT=$(mktemp -d)
cp "$PACKAGE_JSON" "$TMP_PROJECT"/

if ! (cd "$TMP_PROJECT" && yarn install --offline --ignore-scripts --non-interactive > /dev/null); then
  echo "yarn install --offline failed to resolve packages from the cache"
  rm -rf "$TMP_PROJECT"
  exit 1
fi

rm -rf "$TMP_PROJECT"
