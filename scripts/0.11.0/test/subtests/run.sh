#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_run_command() {
  export COMMAND='$PHP_BIN bin/migrate'
  export DEPLOY_PATH=app
  run_script run
  assert_status 0 "$STATUS"
  assert_equal "$(ssh_line "cd '/srv/staging/app' && \$PHP_BIN bin/migrate")" "$(calls)"
}

function test_run_requires_command() {
  run_script run
  assert_status 1 "$STATUS"
  assert_contains "COMMAND" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_run_propagates_exit_status() {
  export COMMAND="false"
  export SSH_STUB_EXIT=3
  run_script run
  assert_status 3 "$STATUS"
}

function test_run_executes_in_staging() {
  export SSH_STUB_EXEC=1
  export SSH_REMOTE_TEMP_DIR="$TEST_TMP/stag ing"
  mkdir -p "$SSH_REMOTE_TEMP_DIR"
  export COMMAND="pwd > out.txt"
  run_script run
  assert_status 0 "$STATUS"
  assert_equal "$TEST_TMP/stag ing" "$(cat "$TEST_TMP/stag ing/out.txt")"

  export COMMAND="exit 7"
  run_script run
  assert_status 7 "$STATUS" "remote command status"
}

run_test test_run_command
run_test test_run_requires_command
run_test test_run_propagates_exit_status
run_test test_run_executes_in_staging
finish
