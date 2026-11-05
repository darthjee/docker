#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function ssh_e() {
  printf '%s' "ssh -i $HOME/ssh_key -p 22 -o StrictHostKeyChecking=no"
}

function test_upload() {
  export SOURCE=dist/
  export DEPLOY_PATH=public/admin/
  export CIRCLE_WORKFLOW_WORKSPACE_ID=w1
  run_script upload
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "mkdir -p '/srv/staging-w1/public/admin'")
$(call_line rsync -avz -e "$(ssh_e)" dist/ "user@host.example.com:/srv/staging-w1/public/admin")" \
    "$(calls)"
}

function test_upload_with_exclude_from() {
  export SOURCE=build/backend/
  export EXCLUDE_FROM=deploy/exclude.txt
  run_script upload
  assert_status 0 "$STATUS"
  assert_equal \
    "$(ssh_line "mkdir -p '/srv/staging'")
$(call_line rsync -avz --exclude-from=deploy/exclude.txt -e "$(ssh_e)" build/backend/ "user@host.example.com:/srv/staging")" \
    "$(calls)"
}

function test_upload_requires_source() {
  run_script upload
  assert_status 1 "$STATUS"
  assert_contains "SOURCE" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_failing_rsync_fails_the_action() {
  export SOURCE=dist/
  export RSYNC_STUB_EXIT=23
  run_script upload
  assert_status 23 "$STATUS"
}

function test_failing_mkdir_skips_rsync() {
  export SOURCE=dist/
  export SSH_STUB_EXIT=255
  run_script upload
  assert_status 255 "$STATUS"
  assert_equal "$(ssh_line "mkdir -p '/srv/staging'")" "$(calls)"
}

run_test test_upload
run_test test_upload_with_exclude_from
run_test test_upload_requires_source
run_test test_failing_rsync_fails_the_action
run_test test_failing_mkdir_skips_rsync
finish
