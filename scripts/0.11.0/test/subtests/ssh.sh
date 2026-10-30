#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../helper.sh"

function test_default_ssh_options() {
  export DEPLOY_PATH=dist
  run_script generate_folder
  assert_equal "$(ssh_line "mkdir -p '/srv/staging/dist'")" "$(calls)"
}

function test_custom_port() {
  export SSH_PORT=2222
  run_script generate_folder
  assert_equal \
    "$(call_line ssh -i "$HOME/ssh_key" -p 2222 -o StrictHostKeyChecking=no user@host.example.com "mkdir -p '/srv/staging'")" \
    "$(calls)"
}

function test_known_hosts_options() {
  export SSH_KNOWN_HOSTS="host.example.com ssh-ed25519 AAAA"
  run_script generate_folder
  assert_equal \
    "$(call_line ssh -i "$HOME/ssh_key" -p 22 -o StrictHostKeyChecking=yes -o "UserKnownHostsFile=$HOME/ssh_known_hosts" user@host.example.com "mkdir -p '/srv/staging'")" \
    "$(calls)"
}

function test_missing_ssh_user_fails() {
  unset SSH_USER
  run_script generate_folder
  assert_status 1 "$STATUS"
  assert_contains "SSH_USER" "$OUTPUT"
  assert_equal "" "$(calls)" "no remote call expected"
}

function test_generate_key_file() {
  export SSH_PRIVATE_KEY='-----BEGIN KEY-----\nabc\n-----END KEY-----'
  run_script generate_key_file
  assert_status 0 "$STATUS"
  assert_equal "$(printf '%s\n' '-----BEGIN KEY-----' abc '-----END KEY-----')" "$(cat "$HOME/ssh_key")"
  assert_equal "3" "$(wc -l < "$HOME/ssh_key" | tr -d ' ')" "key file line count"
  assert_equal "-rw-------" "$(ls -l "$HOME/ssh_key" | cut -c1-10)" "key file mode"
  [ ! -e "$HOME/ssh_known_hosts" ] || fail "known hosts file should not be written"
}

function test_generate_key_file_with_known_hosts() {
  export SSH_PRIVATE_KEY='key'
  export SSH_KNOWN_HOSTS='host1 ssh-ed25519 AAA\nhost2 ssh-rsa BBB'
  run_script generate_key_file
  assert_status 0 "$STATUS"
  assert_equal "$(printf '%s\n' 'host1 ssh-ed25519 AAA' 'host2 ssh-rsa BBB')" "$(cat "$HOME/ssh_known_hosts")"
}

function test_generate_key_file_requires_key() {
  run_script generate_key_file
  assert_status 1 "$STATUS"
  assert_contains "SSH_PRIVATE_KEY" "$OUTPUT"
}

run_test test_default_ssh_options
run_test test_custom_port
run_test test_known_hosts_options
run_test test_missing_ssh_user_fails
run_test test_generate_key_file
run_test test_generate_key_file_with_known_hosts
run_test test_generate_key_file_requires_key
finish
