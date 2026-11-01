#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_release_command() {
  export DATE_STUB=1700000000
  export CIRCLE_WORKFLOW_WORKSPACE_ID=w1
  export DEPLOY_PATH=ignored
  run_script release
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "test -d '/srv/staging-w1' && { [ ! -e '/srv/site' ] || { rm -rf '/srv/site_old_1700000000' && mv '/srv/site' '/srv/site_old_1700000000'; }; } && mv '/srv/staging-w1' '/srv/site' && rm -rf '/srv/site_old_1700000000'")" \
    "$(calls)"
}

function test_release_command_keep_old() {
  export DATE_STUB=1700000000
  export KEEP_OLD=true
  run_script release
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "test -d '/srv/staging' && { [ ! -e '/srv/site' ] || { rm -rf '/srv/site_old_1700000000' && mv '/srv/site' '/srv/site_old_1700000000'; }; } && mv '/srv/staging' '/srv/site'")" \
    "$(calls)"
}

function test_release_requires_remote_dir() {
  unset SSH_REMOTE_DIR
  run_script release
  assert_status 1 "$STATUS"
  assert_contains "SSH_REMOTE_DIR" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function setup_real_release() {
  export SSH_STUB_EXEC=1
  export DATE_STUB=1700000000
  export SSH_REMOTE_TEMP_DIR="$TEST_TMP/stag ing"
  export SSH_REMOTE_DIR="$TEST_TMP/si te"
}

function test_release_first_deploy() {
  setup_real_release
  mkdir -p "$SSH_REMOTE_TEMP_DIR"
  echo new > "$SSH_REMOTE_TEMP_DIR/index.html"
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "new" "$(cat "$SSH_REMOTE_DIR/index.html")"
  [ ! -e "$SSH_REMOTE_TEMP_DIR" ] || fail "staging should be moved"
}

function test_release_swap() {
  setup_real_release
  mkdir -p "$SSH_REMOTE_TEMP_DIR" "$SSH_REMOTE_DIR"
  echo new > "$SSH_REMOTE_TEMP_DIR/index.html"
  echo old > "$SSH_REMOTE_DIR/index.html"
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "new" "$(cat "$SSH_REMOTE_DIR/index.html")"
  [ ! -e "${SSH_REMOTE_DIR}_old_1700000000" ] || fail "old folder should be removed"
  [ ! -e "$SSH_REMOTE_TEMP_DIR" ] || fail "staging should be moved"
}

function test_release_swap_keep_old() {
  setup_real_release
  export KEEP_OLD=true
  mkdir -p "$SSH_REMOTE_TEMP_DIR" "$SSH_REMOTE_DIR"
  echo new > "$SSH_REMOTE_TEMP_DIR/index.html"
  echo old > "$SSH_REMOTE_DIR/index.html"
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "new" "$(cat "$SSH_REMOTE_DIR/index.html")"
  assert_equal "old" "$(cat "${SSH_REMOTE_DIR}_old_1700000000/index.html")"
}

function test_release_missing_staging() {
  setup_real_release
  mkdir -p "$SSH_REMOTE_DIR"
  echo live > "$SSH_REMOTE_DIR/index.html"
  run_script release
  [ "$STATUS" -ne 0 ] || fail "release should fail without staging"
  assert_equal "live" "$(cat "$SSH_REMOTE_DIR/index.html")" "live folder untouched"
  [ ! -e "${SSH_REMOTE_DIR}_old_1700000000" ] || fail "live folder should not be moved"
}

run_test test_release_command
run_test test_release_command_keep_old
run_test test_release_requires_remote_dir
run_test test_release_first_deploy
run_test test_release_swap
run_test test_release_swap_keep_old
run_test test_release_missing_staging
finish
