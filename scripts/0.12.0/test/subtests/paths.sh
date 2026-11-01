#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_workspace_temp_dir_without_workspace_id() {
  source "$SCRIPT"
  assert_equal "/srv/staging" "$(workspace_temp_dir)"
}

function test_workspace_temp_dir_with_workspace_id() {
  export CIRCLE_WORKFLOW_WORKSPACE_ID=abc123
  export SSH_REMOTE_TEMP_DIR=/srv/staging/
  source "$SCRIPT"
  assert_equal "/srv/staging-abc123" "$(workspace_temp_dir)"
}

function test_remote_temp_dir_without_deploy_path() {
  source "$SCRIPT"
  assert_equal "/srv/staging" "$(remote_temp_dir)"
}

function test_remote_temp_dir_with_deploy_path() {
  export DEPLOY_PATH=public/admin/
  source "$SCRIPT"
  assert_equal "/srv/staging/public/admin" "$(remote_temp_dir)"
}

function test_remote_temp_dir_with_workspace_id_and_deploy_path() {
  export CIRCLE_WORKFLOW_WORKSPACE_ID=abc123
  export DEPLOY_PATH=config/.env
  source "$SCRIPT"
  assert_equal "/srv/staging-abc123/config/.env" "$(remote_temp_dir)"
}

function test_missing_remote_temp_dir_fails() {
  unset SSH_REMOTE_TEMP_DIR
  export DEPLOY_PATH=dist
  run_script generate_folder
  assert_status 1 "$STATUS"
  assert_contains "SSH_REMOTE_TEMP_DIR" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_quote_plain_value() {
  source "$SCRIPT"
  assert_equal "'/srv/site'" "$(quote /srv/site)"
}

function test_quote_round_trip() {
  source "$SCRIPT"
  local value
  for value in "/srv/my site" "it's here" "a 'b' \"c\"" '$(rm -rf /); `x` & y; z' ""; do
    assert_equal "$value" "$(sh -c "printf '%s' $(quote "$value")")" "round trip of: $value"
  done
}

run_test test_workspace_temp_dir_without_workspace_id
run_test test_workspace_temp_dir_with_workspace_id
run_test test_remote_temp_dir_without_deploy_path
run_test test_remote_temp_dir_with_deploy_path
run_test test_remote_temp_dir_with_workspace_id_and_deploy_path
run_test test_missing_remote_temp_dir_fails
run_test test_quote_plain_value
run_test test_quote_round_trip
finish
