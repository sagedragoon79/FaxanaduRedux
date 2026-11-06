# Pass 493: A room shot on any machine, xvfb or not

## Category

Tooling. From the top of the workbench queue: port `tools/screenshot.sh` to Windows, which lacks
`xvfb-run`. Rubric scores are unchanged; this pass is loop infrastructure, not game behaviour.

## Audit

`tools/screenshot.sh` drove the game's own `--shot=` capture path (`scripts/game.gd`) under a virtual
display: its only machine-specific line was `xvfb-run -a -s "-screen 0 1280x720x24" ...`. On this PC
`xvfb-run` is absent, so the script failed at once and the scheduled loop had to spell the Godot command
out by hand each time. The workbench's own capture (`workbench/capture/capture_all.py`) already shoots
headlessly on Windows by opening the window off-screen: `--position -8000,-8000 --fixed-fps 60`, default
driver, forward-slash paths. The game's `--shot=` path and every flag it reads (`--shot-at`, `--room`,
`--film`, ...) were intact; nothing in the game needed changing.

## Bug found

None. A port: the script worked on Linux and simply could not run where `xvfb-run` is missing.

## Fix

`tools/screenshot.sh` now picks its display at run time, keeping its documented CLI
(`OUT.png [TILE_X,TILE_Y or -] [ROOM_ID] [extra Godot options]`):

- With `xvfb-run` present (Linux, CI), the old virtual-display invocation runs unchanged.
- Without it, the game window opens off-screen at `-8000,-8000` with `--fixed-fps 60`, matching the proven
  workbench capture.
- The output path is handed to Godot as a native path with forward slashes — `cygpath -m -a` on Windows,
  `realpath -m` elsewhere — so `C:/...` reaches `img.save_png` intact.

Verified by two live captures on this PC (no xvfb): `gym/gym` and `hearthroot/plaza` with a room id, each
a well-formed PNG of the expected room. `docs/architecture.md` and `CLAUDE.md` keep the same
`tools/screenshot.sh` usage; CLAUDE.md gains a note that it falls back to an off-screen window.

No GDScript test: the script is dev tooling outside the game and the `tests/` harness, so the proof is the
two captures rather than a unit test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. The capture script now runs on this PC. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 494: Stability.
