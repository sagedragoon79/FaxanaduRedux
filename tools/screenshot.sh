#!/usr/bin/env bash
# Captures a screenshot of a room. Uses a virtual display (xvfb-run) when one is
# available, and otherwise renders in a real game window moved off-screen, so the
# script also works on machines without xvfb (Windows, macOS).
# Usage: tools/screenshot.sh OUT.png [TILE_X,TILE_Y or -] [ROOM_ID]
#   ROOM_ID is a room under levels/ such as hearthroot/plaza (default gym/gym).
#   "-" (or no tile) puts the player at the room's spawn or first door.
#   Extra Godot game options can follow, e.g. --open=skills or --map.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
# Godot reads the path verbatim, so hand it a native path with forward slashes
# (C:/... on Windows via cygpath, /abs/... elsewhere via realpath).
if command -v cygpath >/dev/null 2>&1; then
	OUT="$(cygpath -m -a "$1")"
else
	OUT="$(realpath -m "$1")"
fi
ARGS=(--shot="$OUT" --shot-frames=40 --room="${3:-gym/gym}")
[[ $# -ge 2 && "$2" != "-" ]] && ARGS+=(--shot-at="$2")
[[ $# -ge 4 ]] && ARGS+=("${@:4}")

if command -v xvfb-run >/dev/null 2>&1; then
	xvfb-run -a -s "-screen 0 1280x720x24" "$GODOT" --path . --rendering-driver opengl3 --fixed-fps 60 -- "${ARGS[@]}"
else
	# No virtual display: open the window off-screen, matching workbench/capture.
	"$GODOT" --path . --position -8000,-8000 --fixed-fps 60 -- "${ARGS[@]}"
fi
