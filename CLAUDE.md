# Faxanadu Redux: notes for agents

Sean (the owner) wants to be hands-off. Make design decisions yourself, consistent with
`docs/design-bible.md`, which is the source of truth. If you deviate from it, update the
bible in the same pull request and say why. Keep the Claude Doc version in sync when the
bible changes substantially (link in the project memory).

## Engine and commands

- Godot **4.7.2** (pinned in `tools/godot-version.txt`). GDScript with static typing.
- Run tests: `GODOT=<godot binary> tools/run_tests.sh` (must pass before merging).
- Screenshot a room: `GODOT=<godot binary> tools/screenshot.sh out.png [tileX,tileY] [room]`.
  Look at screenshots of anything visual you change.
- Regenerate sound effects: `python3 tools/audio/sfxgen.py`. Placeholder music and ambience:
  `python3 tools/audio/musicgen.py` (needs ffmpeg). A file Sean supplies with the same name in
  `assets/music/` (.ogg, .mp3 or .wav) replaces a placeholder. Palette: `python3 tools/art/palette.py`.
- Regenerate zone tilesets and parallax backgrounds: `python3 tools/art/tilegen.py` (every new
  zone folder in `levels/` needs a material spec there; a test checks it).
- Player sprite sheet: `python3 tools/art/spritegen.py`. Enemy and NPC sheets (NPCs from their
  `look` in `data/npcs.json`; rerun after adding a person): `python3 tools/art/castgen.py`. Room decor atlases:
  `python3 tools/art/decorgen.py`. Screenshot one player frame with `--shot-pose=slash1:1`.
- UI pixel font (every glyph is drawn in the script; `PixelFont` loads it): `python3 tools/art/fontgen.py`.
  Draw UI text with `PixelFont.draw`, never `draw_string` with another font.

## Conventions

- Most nodes are built in code (`class_name` scripts), not hand-edited `.tscn` files.
- Rooms are text files in `levels/` loaded by `scripts/world/room.gd`. Legend, doors and map
  placement in `levels/README.md`. `World` moves the player between rooms.
- Anything that must survive a room change or a save lives in `GameState.data`, not on nodes.
- New rooms must pass `tests/test_reachability.gd` (critical path, pickups, no soft-locks).
  Layout rules of thumb are at the end of `levels/README.md`.
  The gym is generated: edit `tools/levels/gen_gym.py`, then run it.
- Enemies extend `Enemy` and must telegraph attacks for at least `Enemy.MIN_TELEGRAPH`.
- Combat numbers live in `scripts/player/combat_tuning.gd` (design bible 5.3).
- Movement numbers live in `scripts/player/movement_tuning.gd` and must match design bible
  section 6. Change both together and keep `tests/` asserting them.
- The player reads intent from `PlayerInput`, never from `Input` directly, so tests can script it.
- Player options live in `Settings` (`scripts/data/settings.gd`, saved to user://settings.cfg). The game
  loads them at start; tests never do, and tests that change them must point `Settings.path` elsewhere.
- Collision layers: see `docs/architecture.md`.
- Every new mechanic gets a test in `tests/`.
- Autosprite credits are limited: log every call in `art/autosprite-ledger.csv` and spend them
  only on character animation (design bible section 13.2).

## The iteration loop

Each pass: build, run tests and screenshots, review against the bible, score the rubric
(design bible 15.3), and record it in `docs/loop/pass-NN.md`. Fix the lowest categories next.
