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

function test_release_command_keep_old_count() {
  local expected
  export DATE_STUB=1700000000
  export KEEP_OLD=2
  IFS= read -r -d '' expected <<'EOF' || true
test -d '/srv/staging' && { [ ! -e '/srv/site' ] || { rm -rf '/srv/site_old_1700000000' && mv '/srv/site' '/srv/site_old_1700000000'; }; } && mv '/srv/staging' '/srv/site' && for d in '/srv/site_old_'*; do ts=${d#'/srv/site_old_'}; case $ts in ''|*[!0-9]*) continue ;; esac; [ -d "$d" ] && echo "$ts"; done | sort -rn | tail -n +3 | while read -r ts; do rm -rf '/srv/site_old_'"$ts" || exit 1; printf 'Removed old folder: %s\n' '/srv/site_old_'"$ts"; done
EOF
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "$(ssh_line "${expected%$'\n'}")" "$(calls)"
}

function test_release_invalid_keep_old() {
  local value
  for value in yes -1 1.5 ' 2'; do
    export KEEP_OLD="$value"
    : > "$STUB_LOG"
    run_script release
    assert_status 1 "$STATUS" "KEEP_OLD='$value' should fail"
    assert_contains "KEEP_OLD" "$OUTPUT"
    assert_equal "" "$(calls)" "no remote call expected for KEEP_OLD='$value'"
  done
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

# Creates the staging and live folders plus one ${SSH_REMOTE_DIR}_old_<suffix>
# folder per argument
function setup_old_folders() {
  local suffix
  mkdir -p "$SSH_REMOTE_TEMP_DIR" "$SSH_REMOTE_DIR"
  echo new > "$SSH_REMOTE_TEMP_DIR/index.html"
  echo old > "$SSH_REMOTE_DIR/index.html"
  for suffix in "$@"; do
    mkdir -p "${SSH_REMOTE_DIR}_old_$suffix"
  done
}

# Lists the suffixes of the remaining ${SSH_REMOTE_DIR}_old_* folders, sorted
function old_suffixes() {
  local dir
  for dir in "${SSH_REMOTE_DIR}_old_"*; do
    [ -d "$dir" ] && printf '%s\n' "${dir#"${SSH_REMOTE_DIR}_old_"}"
  done | sort
}

function test_release_keep_old_zero() {
  setup_real_release
  export KEEP_OLD=0
  setup_old_folders
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "new" "$(cat "$SSH_REMOTE_DIR/index.html")"
  [ ! -e "${SSH_REMOTE_DIR}_old_1700000000" ] || fail "old folder should be removed"
}

function test_release_prunes_old_folders() {
  setup_real_release
  export KEEP_OLD=2
  setup_old_folders 1600000000 1650000000 1690000000
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "new" "$(cat "$SSH_REMOTE_DIR/index.html")"
  assert_equal "old" "$(cat "${SSH_REMOTE_DIR}_old_1700000000/index.html")"
  assert_equal "$(printf '%s\n' 1690000000 1700000000)" "$(old_suffixes)"
  assert_contains "Removed old folder: ${SSH_REMOTE_DIR}_old_1600000000" "$OUTPUT"
  assert_contains "Removed old folder: ${SSH_REMOTE_DIR}_old_1650000000" "$OUTPUT"
}

function test_release_keep_old_one() {
  setup_real_release
  export KEEP_OLD=1
  setup_old_folders 1600000000 1690000000
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "old" "$(cat "${SSH_REMOTE_DIR}_old_1700000000/index.html")"
  assert_equal "1700000000" "$(old_suffixes)"
}

function test_release_prune_ignores_non_numeric() {
  setup_real_release
  export KEEP_OLD=1
  setup_old_folders 1600000000 backup 12a
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "$(printf '%s\n' 12a 1700000000 backup)" "$(old_suffixes)"
  assert_equal "Removed old folder: ${SSH_REMOTE_DIR}_old_1600000000" "$OUTPUT"
}

function test_release_prune_numeric_order() {
  setup_real_release
  export KEEP_OLD=2
  setup_old_folders 999 1600000000
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "$(printf '%s\n' 1600000000 1700000000)" "$(old_suffixes)"
  assert_equal "Removed old folder: ${SSH_REMOTE_DIR}_old_999" "$OUTPUT"
}

function test_release_keep_old_true_keeps_all() {
  setup_real_release
  export KEEP_OLD=true
  setup_old_folders 1600000000 1650000000 1690000000
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "$(printf '%s\n' 1600000000 1650000000 1690000000 1700000000)" "$(old_suffixes)"
  assert_equal "" "$OUTPUT"
}

function test_release_invalid_keep_old_changes_nothing() {
  setup_real_release
  export KEEP_OLD=yes
  setup_old_folders 1600000000
  run_script release
  assert_status 1 "$STATUS"
  assert_equal "old" "$(cat "$SSH_REMOTE_DIR/index.html")" "live folder untouched"
  assert_equal "new" "$(cat "$SSH_REMOTE_TEMP_DIR/index.html")" "staging untouched"
  assert_equal "1600000000" "$(old_suffixes)"
}

function test_release_prune_first_deploy() {
  setup_real_release
  export KEEP_OLD=2
  mkdir -p "$SSH_REMOTE_TEMP_DIR"
  echo new > "$SSH_REMOTE_TEMP_DIR/index.html"
  run_script release
  assert_status 0 "$STATUS"
  assert_equal "new" "$(cat "$SSH_REMOTE_DIR/index.html")"
  assert_equal "" "$(old_suffixes)"
  assert_equal "" "$OUTPUT"
}

run_test test_release_command
run_test test_release_command_keep_old
run_test test_release_command_keep_old_count
run_test test_release_invalid_keep_old
run_test test_release_requires_remote_dir
run_test test_release_first_deploy
run_test test_release_swap
run_test test_release_swap_keep_old
run_test test_release_missing_staging
run_test test_release_keep_old_zero
run_test test_release_prunes_old_folders
run_test test_release_keep_old_one
run_test test_release_prune_ignores_non_numeric
run_test test_release_prune_numeric_order
run_test test_release_keep_old_true_keeps_all
run_test test_release_invalid_keep_old_changes_nothing
run_test test_release_prune_first_deploy
finish
