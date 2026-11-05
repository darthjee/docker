#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_link_with_deploy_path() {
  export SOURCE="/home/user/pidgey shared/.env"
  export DEPLOY_PATH=config/.env
  export CIRCLE_WORKFLOW_WORKSPACE_ID=w1
  run_script link
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "mkdir -p '/srv/staging-w1/config' && ln -sfn '/home/user/pidgey shared/.env' '/srv/staging-w1/config/.env'")" \
    "$(calls)"
}

function test_link_with_deploy_path_trailing_slash() {
  export SOURCE=/home/user/uploads
  export DEPLOY_PATH=public/uploads/
  run_script link
  assert_equal \
    "$(ssh_line "mkdir -p '/srv/staging/public' && ln -sfn '/home/user/uploads' '/srv/staging/public/uploads'")" \
    "$(calls)"
}

function test_link_with_target() {
  export SOURCE=/home/user/uploads
  export TARGET=/srv/staging/uploads
  run_script link
  assert_status 0 "$STATUS"
  assert_equal "$(ssh_line "ln -sfn '/home/user/uploads' '/srv/staging/uploads'")" "$(calls)"
}

function test_link_without_deploy_path_nor_target() {
  export SOURCE=/home/user/uploads
  run_script link
  assert_status 1 "$STATUS"
  assert_contains "DEPLOY_PATH or TARGET" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_link_requires_source() {
  export DEPLOY_PATH=config/.env
  run_script link
  assert_status 1 "$STATUS"
  assert_contains "SOURCE" "$OUTPUT"
}

function test_link_really_links() {
  export SSH_STUB_EXEC=1
  export SSH_REMOTE_TEMP_DIR="$TEST_TMP/stag ing"
  mkdir -p "$TEST_TMP/shared"
  echo secret > "$TEST_TMP/shared/.env"
  export SOURCE="$TEST_TMP/shared/.env"
  export DEPLOY_PATH=config/.env
  run_script link
  assert_status 0 "$STATUS"
  assert_equal "secret" "$(cat "$TEST_TMP/stag ing/config/.env")"
  run_script link
  assert_status 0 "$STATUS" "linking again succeeds"
}

run_test test_link_with_deploy_path
run_test test_link_with_deploy_path_trailing_slash
run_test test_link_with_target
run_test test_link_without_deploy_path_nor_target
run_test test_link_requires_source
run_test test_link_really_links
finish
