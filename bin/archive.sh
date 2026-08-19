#!/bin/bash

function current_version() {
  local image=$1
  grep "^${image}=" version | sed -e "s/${image}=//g"
}

function image_versions() {
  local image=$1
  find "$image" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -V
}

function previous_version() {
  local image=$1
  local current
  current=$(current_version "$image")
  image_versions "$image" | grep -v "^${current}$" | tail -1
}

function versions_to_remove() {
  local image=$1
  local up_to=$2

  if ! image_versions "$image" | grep -qx "$up_to"; then
    echo "Version $up_to not found in $image" >&2
    return 1
  fi

  image_versions "$image" | awk -v target="$up_to" '{
    print
    if ($0 == target) exit
  }'
}

function remove_from_version_file() {
  local image=$1
  grep -v "^${image}=" version > aux
  mv aux version
}

function remove_from_readme() {
  local image=$1
  grep -v "^  - \[${image}:" README.md > aux
  mv aux README.md
}

function remove_from_circleci() {
  local image=$1
  python3 - "$image" << 'PYEOF'
import sys

image = sys.argv[1]

with open('.circleci/config.yml', 'r') as f:
    content = f.read()

marker = '      - release:\n'
parts = content.split(marker)

result_parts = [parts[0]]
for part in parts[1:]:
    if f'          name: release-{image}\n' not in part:
        result_parts.append(part)

result = marker.join(result_parts)

with open('.circleci/config.yml', 'w') as f:
    f.write(result)
PYEOF
}

function archive() {
  local image=$2
  local version=$3

  if [ ! "$image" ]; then
    echo "Usage: $0 archive <image_name> [version]"
    return 1
  fi

  if [ ! -d "$image" ]; then
    echo "Image folder $image not found"
    return 1
  fi

  if [ ! "$version" ]; then
    local count
    count=$(image_versions "$image" | wc -l | tr -d ' ')

    if [ "$count" -le 1 ]; then
      echo "Nothing to archive: $image has only one version"
      return 0
    fi

    version=$(previous_version "$image")
  fi

  local to_remove
  to_remove=$(versions_to_remove "$image" "$version") || return 1

  for v in $to_remove; do
    echo "Removing $image/$v"
    rm -rf "$image/$v"
  done

  local remaining
  remaining=$(image_versions "$image")

  if [ -z "$remaining" ]; then
    echo "No versions remaining, removing $image entirely"
    rm -rf "$image"
    remove_from_version_file "$image"
    remove_from_readme "$image"
    remove_from_circleci "$image"
  fi
}
