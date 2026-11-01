#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_cleanup_command() {
  export CIRCLE_WORKFLOW_WORKSPACE_ID=w1
  run_script cleanup
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "[ ! -d '/srv' ] || find '/srv' -mindepth 1 -maxdepth 1 -type d -name 'staging-*' -mmin +1440 ! -name 'staging-w1' -exec rm -rf {} ';'")" \
    "$(calls)"
}

function test_cleanup_command_without_workspace() {
  run_script cleanup
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "[ ! -d '/srv' ] || find '/srv' -mindepth 1 -maxdepth 1 -type d -name 'staging-*' -mmin +1440 -exec rm -rf {} ';'")" \
    "$(calls)"
}

function test_cleanup_command_max_age() {
  export CLEANUP_MAX_AGE_MINUTES=60
  run_script cleanup
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "[ ! -d '/srv' ] || find '/srv' -mindepth 1 -maxdepth 1 -type d -name 'staging-*' -mmin +60 -exec rm -rf {} ';'")" \
    "$(calls)"
}

function test_cleanup_command_trailing_slash() {
  export CIRCLE_WORKFLOW_WORKSPACE_ID=w1
  export SSH_REMOTE_TEMP_DIR=/srv/staging/
  run_script cleanup
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "[ ! -d '/srv' ] || find '/srv' -mindepth 1 -maxdepth 1 -type d -name 'staging-*' -mmin +1440 ! -name 'staging-w1' -exec rm -rf {} ';'")" \
    "$(calls)"
}

function test_cleanup_requires_temp_dir() {
  unset SSH_REMOTE_TEMP_DIR
  run_script cleanup
  assert_status 1 "$STATUS"
  assert_contains "SSH_REMOTE_TEMP_DIR" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_cleanup_requires_ssh_user() {
  unset SSH_USER
  run_script cleanup
  assert_status 1 "$STATUS"
  assert_contains "SSH_USER" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_cleanup_invalid_max_age() {
  export CLEANUP_MAX_AGE_MINUTES=abc
  run_script cleanup
  assert_status 1 "$STATUS"
  assert_contains "CLEANUP_MAX_AGE_MINUTES" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function setup_real_cleanup() {
  export SSH_STUB_EXEC=1
  export SSH_REMOTE_TEMP_DIR="$TEST_TMP/stag ing"
  export SSH_REMOTE_DIR="$TEST_TMP/si te"
}

# Creates a folder with a file inside, aging it after the file is written
function make_old_folder() {
  mkdir -p "$1"
  echo content > "$1/index.html"
  touch -t 200001010000 "$1"
}

function test_cleanup_removes_old_staging_folders() {
  setup_real_cleanup
  export CIRCLE_WORKFLOW_WORKSPACE_ID=w1
  make_old_folder "$SSH_REMOTE_TEMP_DIR-old"
  make_old_folder "$SSH_REMOTE_TEMP_DIR-w1"
  mkdir -p "$SSH_REMOTE_TEMP_DIR-new"
  make_old_folder "$SSH_REMOTE_TEMP_DIR"
  make_old_folder "$SSH_REMOTE_DIR"
  make_old_folder "${SSH_REMOTE_DIR}_old_1"
  run_script cleanup
  assert_status 0 "$STATUS"
  [ ! -e "$SSH_REMOTE_TEMP_DIR-old" ] || fail "old staging folder should be removed"
  [ -d "$SSH_REMOTE_TEMP_DIR-w1" ] || fail "current staging folder should be kept"
  [ -d "$SSH_REMOTE_TEMP_DIR-new" ] || fail "recent staging folder should be kept"
  [ -d "$SSH_REMOTE_TEMP_DIR" ] || fail "plain temp folder should be kept"
  [ -d "$SSH_REMOTE_DIR" ] || fail "live folder should be kept"
  [ -d "${SSH_REMOTE_DIR}_old_1" ] || fail "old live folder should be kept"
}

function test_cleanup_missing_parent() {
  setup_real_cleanup
  export SSH_REMOTE_TEMP_DIR="$TEST_TMP/miss ing/staging"
  run_script cleanup
  assert_status 0 "$STATUS"
}

run_test test_cleanup_command
run_test test_cleanup_command_without_workspace
run_test test_cleanup_command_max_age
run_test test_cleanup_command_trailing_slash
run_test test_cleanup_requires_temp_dir
run_test test_cleanup_requires_ssh_user
run_test test_cleanup_invalid_max_age
run_test test_cleanup_removes_old_staging_folders
run_test test_cleanup_missing_parent
finish
