#!/usr/bin/env bats

load 'bats-support/load.bash'
load 'bats-assert/load.bash'

setup() {
    export NO_COLOR=1
    export PHX_SCRIPT="$(pwd)/phx.sh"

    # Create a temporary directory for dummy PHP binaries
    BIN_DIR="$(mktemp -d -t phx-bin-XXXXXX)"
    export PHX_BIN_PATHS_DEFAULT="$BIN_DIR"

    # Create dummy php executables
    echo '#!/bin/sh' > "$BIN_DIR/php8.1"
    echo 'echo "PHP 8.1.0 (dummy)"' >> "$BIN_DIR/php8.1"
    chmod +x "$BIN_DIR/php8.1"

    echo '#!/bin/sh' > "$BIN_DIR/php8.2"
    echo 'echo "PHP 8.2.0 (dummy)"' >> "$BIN_DIR/php8.2"
    chmod +x "$BIN_DIR/php8.2"

    # Create a temporary PHX_DIR
    export PHX_DIR="$(mktemp -d -t phx-dir-XXXXXX)"

    # Add shims to PATH
    export PATH="$PHX_DIR/shims:$PATH"

    # Run init to setup the directory structure
    run "$PHX_SCRIPT" init
}

teardown() {
    rm -rf "$BIN_DIR" "$PHX_DIR"
}

@test "global command sets the php version" {
    run "$PHX_SCRIPT" global 8.2
    assert_success

    # Check if the global version file is updated
    run cat "$PHX_DIR/version"
    assert_output "8.2"

    # Check if the shim is created and points to the correct binary
    run readlink -f "$PHX_DIR/shims/php"
    assert_output "$BIN_DIR/php8.2"
}

@test "local command sets the php version" {
    SUB_DIR="$(mktemp -d -t phx-subdir-XXXXXX)"
    cd "$SUB_DIR"

    run "$PHX_SCRIPT" local 8.1
    assert_success

    [ -f ".phx-version" ]
    run cat ".phx-version"
    assert_output "8.1"

    cd - > /dev/null
    rm -rf "$SUB_DIR"
}

@test "current command shows the active version" {
    run "$PHX_SCRIPT" global 8.2
    assert_success

    run "$PHX_SCRIPT" current
    assert_line --index 0 "phx: Active PHP: 8.2"
    assert_line --index 1 "PHP 8.2.0 (dummy)"

    # Now set a local version
    SUB_DIR="$(mktemp -d -t phx-subdir-XXXXXX)"
    cd "$SUB_DIR"
    run "$PHX_SCRIPT" local 8.1
    assert_success

    # Check current again (should show local)
    run "$PHX_SCRIPT" current
    assert_line --index 0 "phx: Active PHP: 8.1"
    assert_line --index 1 "PHP 8.1.0 (dummy)"

    # Cleanup
    cd - > /dev/null
    rm -rf "$SUB_DIR"
}

@test "which command shows the path to the shim" {
    run "$PHX_SCRIPT" global 8.2
    assert_success

    run "$PHX_SCRIPT" which
    assert_output --partial "php → $BIN_DIR/php8.2"
}
