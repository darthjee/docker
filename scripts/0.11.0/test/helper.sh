#!/bin/bash
# Shared helpers for the deploy_frontend.sh subtests.
# Each test is a function run in a subshell with a clean environment,
# a temporary HOME and the ssh/rsync/date stubs first on PATH.

TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ORIGINAL_PATH="$PATH"

if [ -n "${DEPLOY_FRONTEND:-}" ]; then
  SCRIPT="$DEPLOY_FRONTEND"
elif [ -f /home/scripts/sbin/deploy_frontend.sh ]; then
  SCRIPT=/home/scripts/sbin/deploy_frontend.sh
else
  SCRIPT="$TEST_DIR/../home/sbin/deploy_frontend.sh"
fi

TESTS_RUN=0
TESTS_FAILED=0

function setup_env() {
  unset SSH_PORT SSH_KNOWN_HOSTS SSH_PRIVATE_KEY CIRCLE_WORKFLOW_WORKSPACE_ID \
    DEPLOY_PATH TARGET SOURCE COMMAND EXCLUDE_FROM BUILD_COMMAND KEEP_OLD \
    SSH_STUB_EXIT SSH_STUB_EXEC RSYNC_STUB_EXIT DATE_STUB

  export HOME="$TEST_TMP/home"
  export STUB_LOG="$TEST_TMP/calls.log"
  export PATH="$TEST_DIR/stubs:$ORIGINAL_PATH"
  export SSH_USER=user
  export SSH_HOST=host.example.com
  export SSH_REMOTE_TEMP_DIR=/srv/staging
  export SSH_REMOTE_DIR=/srv/site

  mkdir -p "$HOME"
  : > "$STUB_LOG"
  cd "$TEST_TMP" || exit 1
}

# Builds the line a stub records for a call: "<name> [arg1] [arg2] ..."
function call_line() {
  local name="$1"
  shift
  printf '%s' "$name"
  for arg in "$@"; do
    printf ' [%s]' "$arg"
  done
  printf '\n'
}

# Expected ssh call line with the default options
function ssh_line() {
  call_line ssh -i "$HOME/ssh_key" -p 22 -o StrictHostKeyChecking=no \
    "user@host.example.com" "$1"
}

function fail() {
  echo "    $1"
  : > "$TEST_TMP/failed"
}

function assert_equal() {
  local expected="$1"
  local actual="$2"
  local message="${3:-values differ}"

  if [ "$expected" != "$actual" ]; then
    fail "$message"
    echo "      expected: $expected"
    echo "      actual:   $actual"
  fi
  return 0
}

function assert_status() {
  local expected="$1"
  local actual="$2"
  local message="${3:-unexpected exit status}"

  assert_equal "$expected" "$actual" "$message"
}

function assert_contains() {
  local needle="$1"
  local haystack="$2"
  local message="${3:-text not found}"

  case "$haystack" in
    *"$needle"*) ;;
    *)
      fail "$message"
      echo "      expected to contain: $needle"
      echo "      actual:              $haystack"
      ;;
  esac
  return 0
}

function calls() {
  cat "$STUB_LOG"
}

# Runs the script with the given action, capturing stdout+stderr in $OUTPUT
# and the exit status in $STATUS
function run_script() {
  set +e
  OUTPUT=$(bash "$SCRIPT" "$@" 2>&1)
  STATUS=$?
}

function run_test() {
  local name="$1"
  TESTS_RUN=$((TESTS_RUN + 1))
  TEST_TMP=$(mktemp -d)

  ( setup_env; "$name" )
  local status=$?

  if [ "$status" -ne 0 ] || [ -e "$TEST_TMP/failed" ]; then
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo "  FAIL: $name"
  else
    echo "  ok: $name"
  fi

  rm -rf "$TEST_TMP"
}

function finish() {
  echo "  $TESTS_RUN tests, $TESTS_FAILED failures"
  [ "$TESTS_FAILED" -eq 0 ]
}
