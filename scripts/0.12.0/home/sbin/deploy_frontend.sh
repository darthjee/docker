#!/bin/bash
# Deploys files to a remote host through ssh/rsync using a staging folder
# that is swapped into place by the release action.
#
# Usage: deploy_frontend.sh <action>
# Actions: generate_key_file, build, generate_folder, copy_files, upload,
#          link, run, release, cleanup
set -euo pipefail

SSH_KEY_FILE_PATH="$HOME/ssh_key"
SSH_KNOWN_HOSTS_FILE_PATH="$HOME/ssh_known_hosts"
ACTIONS="generate_key_file build generate_folder copy_files upload link run release cleanup"

# Wraps a value in POSIX single quotes, turning every inner ' into '\''
function quote() {
  local single_quote="'"
  local escaped_quote="'\\''"
  local escaped="${1//$single_quote/$escaped_quote}"
  printf "'%s'" "$escaped"
}

# Converts literal \n sequences into newlines and writes the value to a file
function write_multiline() {
  local value="$1"
  local file="$2"
  printf '%s\n' "${value//\\n/$'\n'}" > "$file"
}

# Required variables are checked in the main shell (never inside a command
# substitution), so a missing one stops the script
function require_ssh() {
  : "${SSH_USER:?SSH_USER is required}"
  : "${SSH_HOST:?SSH_HOST is required}"
}

function require_temp_dir() {
  : "${SSH_REMOTE_TEMP_DIR:?SSH_REMOTE_TEMP_DIR is required}"
}

function require_remote_dir() {
  : "${SSH_REMOTE_DIR:?SSH_REMOTE_DIR is required}"
}

function workspace_temp_dir() {
  local dir="$SSH_REMOTE_TEMP_DIR"
  local workspace_id="${CIRCLE_WORKFLOW_WORKSPACE_ID:-}"

  if [ -n "$workspace_id" ]; then
    printf '%s' "${dir%/}-$workspace_id"
  else
    printf '%s' "$dir"
  fi
}

# DEPLOY_PATH without trailing slashes
function deploy_path() {
  local path="${DEPLOY_PATH:-}"
  while [ "$path" != "${path%/}" ]; do
    path="${path%/}"
  done
  printf '%s' "$path"
}

function remote_temp_dir() {
  local dir
  local path
  dir=$(workspace_temp_dir)
  path=$(deploy_path)

  if [ -n "$path" ]; then
    printf '%s' "${dir%/}/$path"
  else
    printf '%s' "$dir"
  fi
}

# Sets SSH_CMD to the ssh command (as an array) used for every remote call
function build_ssh_command() {
  SSH_CMD=(ssh -i "$SSH_KEY_FILE_PATH" -p "${SSH_PORT:-22}")

  if [ -n "${SSH_KNOWN_HOSTS:-}" ]; then
    SSH_CMD+=(-o StrictHostKeyChecking=yes -o "UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE_PATH")
  else
    SSH_CMD+=(-o StrictHostKeyChecking=no)
  fi
}

# Runs a command string on the remote host
function remote() {
  local command="$1"
  build_ssh_command

  "${SSH_CMD[@]}" "$SSH_USER@$SSH_HOST" "$command"
}

function run_generate_ssh_key_file() {
  : "${SSH_PRIVATE_KEY:?SSH_PRIVATE_KEY is required}"

  write_multiline "$SSH_PRIVATE_KEY" "$SSH_KEY_FILE_PATH"
  chmod 600 "$SSH_KEY_FILE_PATH"

  if [ -n "${SSH_KNOWN_HOSTS:-}" ]; then
    write_multiline "$SSH_KNOWN_HOSTS" "$SSH_KNOWN_HOSTS_FILE_PATH"
    chmod 600 "$SSH_KNOWN_HOSTS_FILE_PATH"
  fi
}

function run_build() {
  ${BUILD_COMMAND:-npm run build}

  if [ -d assets/images/ ]; then
    rsync -r assets/images/ dist/assets/images/
    find dist/assets/images/ -iname "*.pbm" -delete
  fi
}

function run_generate_folder() {
  require_ssh
  require_temp_dir
  local dir
  dir=$(remote_temp_dir)

  remote "mkdir -p $(quote "$dir")"
}

function run_copy_files() {
  require_ssh
  require_temp_dir
  require_remote_dir
  local source="$SSH_REMOTE_DIR/${TARGET:-}"
  local dir
  dir=$(remote_temp_dir)

  remote "cp -R $(quote "$source") $(quote "$dir/")"
}

function run_upload() {
  require_ssh
  require_temp_dir
  : "${SOURCE:?SOURCE is required}"
  local dir
  local rsync_options=(-avz)
  dir=$(remote_temp_dir)

  if [ -n "${EXCLUDE_FROM:-}" ]; then
    rsync_options+=("--exclude-from=$EXCLUDE_FROM")
  fi

  remote "mkdir -p $(quote "$dir")"
  build_ssh_command
  rsync "${rsync_options[@]}" -e "${SSH_CMD[*]}" "$SOURCE" "$SSH_USER@$SSH_HOST:$dir"
}

function run_link() {
  require_ssh
  require_temp_dir
  : "${SOURCE:?SOURCE is required}"
  local path
  local link_path
  local parent
  path=$(deploy_path)

  if [ -n "$path" ]; then
    link_path=$(remote_temp_dir)
    parent=$(dirname "$link_path")
    remote "mkdir -p $(quote "$parent") && ln -sfn $(quote "$SOURCE") $(quote "$link_path")"
  elif [ -n "${TARGET:-}" ]; then
    remote "ln -sfn $(quote "$SOURCE") $(quote "$TARGET")"
  else
    echo "link requires DEPLOY_PATH or TARGET" >&2
    return 1
  fi
}

# COMMAND is sent as is: the caller is responsible for its quoting
function run_run() {
  require_ssh
  require_temp_dir
  : "${COMMAND:?COMMAND is required}"
  local dir
  dir=$(remote_temp_dir)

  remote "cd $(quote "$dir") && $COMMAND"
}

function run_release() {
  require_ssh
  require_temp_dir
  require_remote_dir
  local staging
  local timestamp
  local live
  local old
  local commands
  staging=$(workspace_temp_dir)
  timestamp=$(date +%s)
  live=$(quote "$SSH_REMOTE_DIR")
  old=$(quote "${SSH_REMOTE_DIR}_old_$timestamp")
  staging=$(quote "$staging")

  commands="test -d $staging && { [ ! -e $live ] || { rm -rf $old && mv $live $old; }; } && mv $staging $live"

  if [ "${KEEP_OLD:-}" != "true" ]; then
    commands="$commands && rm -rf $old"
  fi

  remote "$commands"
}

# Removes the ${SSH_REMOTE_TEMP_DIR}-* staging folders older than
# CLEANUP_MAX_AGE_MINUTES, keeping the current workflow's staging folder
function run_cleanup() {
  require_ssh
  require_temp_dir
  local age="${CLEANUP_MAX_AGE_MINUTES:-1440}"
  local dir="${SSH_REMOTE_TEMP_DIR%/}"
  local workspace_id="${CIRCLE_WORKFLOW_WORKSPACE_ID:-}"
  local parent
  local base
  local commands

  case "$age" in
    '' | *[!0-9]*)
      echo "CLEANUP_MAX_AGE_MINUTES must be a number of minutes" >&2
      return 1
      ;;
  esac

  parent=$(dirname "$dir")
  base=$(basename "$dir")
  parent=$(quote "$parent")

  commands="[ ! -d $parent ] || find $parent -mindepth 1 -maxdepth 1 -type d -name $(quote "$base-*") -mmin +$age"

  if [ -n "$workspace_id" ]; then
    commands="$commands ! -name $(quote "$base-$workspace_id")"
  fi

  commands="$commands -exec rm -rf {} ';'"

  remote "$commands"
}

function usage() {
  echo "Usage: deploy_frontend.sh <action>" >&2
  echo "Actions: $ACTIONS" >&2
}

function main() {
  ACTION="${1:-}"

  case "$ACTION" in
    "build")
      run_build
      ;;
    "generate_key_file")
      run_generate_ssh_key_file
      ;;
    "generate_folder")
      run_generate_folder
      ;;
    "copy_files")
      run_copy_files
      ;;
    "upload")
      run_upload
      ;;
    "link")
      run_link
      ;;
    "run")
      run_run
      ;;
    "release")
      run_release
      ;;
    "cleanup")
      run_cleanup
      ;;
    *)
      usage
      return 1
      ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
