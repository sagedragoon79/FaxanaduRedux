#!/usr/bin/env bash
# Runs the headless test suite. Set GODOT to your Godot 4.7.2 binary (default: godot).
# Usage: tools/run_tests.sh [--filter=name_part]
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
"$GODOT" --headless --path . --import >/dev/null 2>&1 || true
# A script that fails to parse leaves Godot running with nothing to do, so cap the run.
timeout "${TEST_TIMEOUT:-1500}" "$GODOT" --headless --path . --fixed-fps 60 res://tests/test_runner.tscn -- "$@"
