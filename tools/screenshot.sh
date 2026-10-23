#!/usr/bin/env bash
# Captures a screenshot of a room under a virtual display (needs xvfb-run).
# Usage: tools/screenshot.sh OUT.png [TILE_X,TILE_Y or -] [ROOM_ID]
#   ROOM_ID is a room under levels/ such as eolis/plaza (default gym/gym).
#   "-" (or no tile) puts the player at the room's spawn or first door.
#   Extra Godot game options can follow, e.g. --open=skills or --map.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
OUT="$(realpath -m "$1")"
ARGS=(--shot="$OUT" --shot-frames=40 --room="${3:-gym/gym}")
[[ $# -ge 2 && "$2" != "-" ]] && ARGS+=(--shot-at="$2")
[[ $# -ge 4 ]] && ARGS+=("${@:4}")
xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --rendering-driver opengl3 --fixed-fps 60 -- "${ARGS[@]}"
