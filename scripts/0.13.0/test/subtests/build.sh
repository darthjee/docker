#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_build_with_custom_command_without_images() {
  export BUILD_COMMAND="touch built.txt"
  run_script build
  assert_status 0 "$STATUS"
  [ -e built.txt ] || fail "build command was not run"
  assert_equal "" "$(calls)" "no rsync expected without assets/images"
}

function test_build_with_images() {
  export BUILD_COMMAND="true"
  mkdir -p assets/images dist/assets/images
  touch dist/assets/images/a.pbm dist/assets/images/b.PBM dist/assets/images/c.png
  run_script build
  assert_status 0 "$STATUS"
  assert_equal "$(call_line rsync -r assets/images/ dist/assets/images/)" "$(calls)"
  assert_equal "c.png" "$(ls dist/assets/images)"
}

function test_failing_build_command() {
  export BUILD_COMMAND="false"
  run_script build
  assert_status 1 "$STATUS"
}

run_test test_build_with_custom_command_without_images
run_test test_build_with_images
run_test test_failing_build_command
finish
