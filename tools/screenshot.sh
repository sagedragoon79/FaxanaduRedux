#!/usr/bin/env bash
# Captures a screenshot of a room under a virtual display (needs xvfb-run).
# Usage: tools/screenshot.sh OUT.png [TILE_X,TILE_Y] [ROOM_PATH]
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
OUT="$(realpath -m "$1")"
ARGS=(--shot="$OUT" --shot-frames=40)
[[ $# -ge 2 ]] && ARGS+=(--shot-at="$2")
[[ $# -ge 3 ]] && ARGS+=(--room="$3")
xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --rendering-driver opengl3 --fixed-fps 60 -- "${ARGS[@]}"
