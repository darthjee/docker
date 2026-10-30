#!/bin/bash
# Deploys files to a remote host through ssh/rsync using a staging folder
# that is swapped into place by the release action.
#
# Usage: deploy_frontend.sh <action>
# Actions: generate_key_file, build, generate_folder, copy_files, upload,
#          link, run, release
set -euo pipefail

SSH_KEY_FILE_PATH="$HOME/ssh_key"
SSH_KNOWN_HOSTS_FILE_PATH="$HOME/ssh_known_hosts"
ACTIONS="generate_key_file build generate_folder copy_files upload link run release"

# Wraps a value in POSIX single quotes, turning every inner ' into '\''
function quote() {
  local escaped="${1//\'/\'\\\'\'}"
  printf "'%s'" "$escaped"
}

# Converts literal \n sequences into newlines and writes the value to a file
function write_multiline() {
  local value="$1"
  local file="$2"
  printf '%s\n' "${value//\\n/$'\n'}" > "$file"
}

function workspace_temp_dir() {
  local dir="${SSH_REMOTE_TEMP_DIR:?SSH_REMOTE_TEMP_DIR is required}"
  local workspace_id="${CIRCLE_WORKFLOW_WORKSPACE_ID:-}"

  if [ -n "$workspace_id" ]; then
    printf '%s' "${dir%/}-$workspace_id"
  else
    printf '%s' "$dir"
  fi
}

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

# Prints the ssh command (one word per line) used for every remote call
function ssh_command() {
  printf '%s\n' ssh -i "$SSH_KEY_FILE_PATH" -p "${SSH_PORT:-22}"
  if [ -n "${SSH_KNOWN_HOSTS:-}" ]; then
    printf '%s\n' -o StrictHostKeyChecking=yes \
      -o "UserKnownHostsFile=$SSH_KNOWN_HOSTS_FILE_PATH"
  else
    printf '%s\n' -o StrictHostKeyChecking=no
  fi
}

function ssh_destination() {
  printf '%s@%s' \
    "${SSH_USER:?SSH_USER is required}" \
    "${SSH_HOST:?SSH_HOST is required}"
}

# Runs a command string on the remote host
function remote() {
  local command="$1"
  local destination
  local ssh_cmd=()
  destination=$(ssh_destination)
  mapfile -t ssh_cmd < <(ssh_command)

  "${ssh_cmd[@]}" "$destination" "$command"
}

function run_generate_ssh_key_file() {
  write_multiline "${SSH_PRIVATE_KEY:?SSH_PRIVATE_KEY is required}" "$SSH_KEY_FILE_PATH"
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
  remote "mkdir -p $(quote "$(remote_temp_dir)")"
}

function run_copy_files() {
  local source="${SSH_REMOTE_DIR:?SSH_REMOTE_DIR is required}/${TARGET:-}"

  remote "cp -R $(quote "$source") $(quote "$(remote_temp_dir)/")"
}

function run_upload() {
  local source="${SOURCE:?SOURCE is required}"
  local dir
  local destination
  local ssh_cmd=()
  local rsync_options=(-avz)
  dir=$(remote_temp_dir)
  destination=$(ssh_destination)
  mapfile -t ssh_cmd < <(ssh_command)

  if [ -n "${EXCLUDE_FROM:-}" ]; then
    rsync_options+=("--exclude-from=$EXCLUDE_FROM")
  fi

  remote "mkdir -p $(quote "$dir")"
  rsync "${rsync_options[@]}" -e "${ssh_cmd[*]}" "$source" "$destination:$dir"
}

function run_link() {
  local source="${SOURCE:?SOURCE is required}"
  local link_path

  if [ -n "$(deploy_path)" ]; then
    link_path=$(remote_temp_dir)
    remote "mkdir -p $(quote "$(dirname "$link_path")") && ln -sfn $(quote "$source") $(quote "$link_path")"
  elif [ -n "${TARGET:-}" ]; then
    remote "ln -sfn $(quote "$source") $(quote "$TARGET")"
  else
    echo "link requires DEPLOY_PATH or TARGET" >&2
    return 1
  fi
}

function run_run() {
  local command="${COMMAND:?COMMAND is required}"

  remote "cd $(quote "$(remote_temp_dir)") && $command"
}

function run_release() {
  local live="${SSH_REMOTE_DIR:?SSH_REMOTE_DIR is required}"
  local staging
  local old
  local commands
  staging=$(workspace_temp_dir)
  old="${live}_old_$(date +%s)"

  local q_live q_staging q_old
  q_live=$(quote "$live")
  q_staging=$(quote "$staging")
  q_old=$(quote "$old")

  commands="test -d $q_staging && { [ ! -e $q_live ] || { rm -rf $q_old && mv $q_live $q_old; }; } && mv $q_staging $q_live"

  if [ "${KEEP_OLD:-}" != "true" ]; then
    commands="$commands && rm -rf $q_old"
  fi

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
    *)
      usage
      return 1
      ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
