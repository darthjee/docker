#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_unknown_action() {
  local stderr
  set +e
  stderr=$(bash "$SCRIPT" unknown 2>&1 >/dev/null)
  local status=$?
  assert_status 1 "$status"
  assert_contains "Actions: generate_key_file build generate_folder copy_files upload link run release" "$stderr"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_missing_action() {
  local stderr
  set +e
  stderr=$(bash "$SCRIPT" 2>&1 >/dev/null)
  local status=$?
  assert_status 1 "$status"
  assert_contains "Actions:" "$stderr"
}

function test_generate_folder() {
  export DEPLOY_PATH=dist
  run_script generate_folder
  assert_status 0 "$STATUS"
  assert_equal "$(ssh_line "mkdir -p '/srv/staging/dist'")" "$(calls)"
}

function test_copy_files() {
  export TARGET="my files"
  run_script copy_files
  assert_status 0 "$STATUS"
  assert_equal "$(ssh_line "cp -R '/srv/site/my files' '/srv/staging/'")" "$(calls)"
}

function test_copy_files_requires_remote_dir() {
  unset SSH_REMOTE_DIR
  run_script copy_files
  assert_status 1 "$STATUS"
  assert_contains "SSH_REMOTE_DIR" "$OUTPUT"
}

function test_failing_ssh_fails_the_action() {
  export SSH_STUB_EXIT=255
  run_script generate_folder
  assert_status 255 "$STATUS"
}

run_test test_unknown_action
run_test test_missing_action
run_test test_generate_folder
run_test test_copy_files
run_test test_copy_files_requires_remote_dir
run_test test_failing_ssh_fails_the_action
finish
