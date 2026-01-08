#!/usr/bin/env bats

load 'bats-support/load.bash'
load 'bats-assert/load.bash'

setup() {
    export NO_COLOR=1
    export PHX_SCRIPT="$(pwd)/phx.sh"

    # Use a temporary directory for PHX_DIR for isolation
    export PHX_DIR="$(mktemp -d -t phx-dir-XXXXXX)"
}

teardown() {
    rm -rf "$PHX_DIR"
}

@test "init command creates the directory structure" {
    run "$PHX_SCRIPT" init
    assert_success
    assert_line --partial "PHX installed on"

    # Check that the directories and files were created
    [ -d "$PHX_DIR" ]
    [ -d "$PHX_DIR/shims" ]
    [ -f "$PHX_DIR/version" ]
}
