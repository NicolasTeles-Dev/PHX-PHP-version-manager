#!/usr/bin/env bats

load 'bats-support/load.bash'
load 'bats-assert/load.bash'

setup() {
  export NO_COLOR=1
  export PHX_SCRIPT="$(pwd)/phx.sh"

  # Create a temporary directory for dummy PHP binaries
  TEST_DIR="$(mktemp -d -t phx-test-XXXXXX)"
  export PHX_BIN_PATHS_DEFAULT="$TEST_DIR"

  # Create dummy php executables
  touch "$TEST_DIR/php8.1"
  touch "$TEST_DIR/php8.2"
  chmod +x "$TEST_DIR/php8.1"
  chmod +x "$TEST_DIR/php8.2"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "list command displays available versions" {
  run "$PHX_SCRIPT" list

  assert_line --index 0 "phx: Available PHP versions:"
  assert_line --index 1 --partial "8.2"
  assert_line --index 2 --partial "8.1"
  assert_success
}
