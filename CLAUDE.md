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
- Regenerate sound effects: `python3 tools/audio/sfxgen.py`. Palette: `python3 tools/art/palette.py`.

## Conventions

- Most nodes are built in code (`class_name` scripts), not hand-edited `.tscn` files.
- Rooms are text files in `levels/` loaded by `scripts/world/room.gd`. Legend, doors and map
  placement in `levels/README.md`. `World` moves the player between rooms.
- Anything that must survive a room change or a save lives in `GameState.data`, not on nodes.
  The gym is generated: edit `tools/levels/gen_gym.py`, then run it.
- Enemies extend `Enemy` and must telegraph attacks for at least `Enemy.MIN_TELEGRAPH`.
- Combat numbers live in `scripts/player/combat_tuning.gd` (design bible 5.3).
- Movement numbers live in `scripts/player/movement_tuning.gd` and must match design bible
  section 6. Change both together and keep `tests/` asserting them.
- The player reads intent from `PlayerInput`, never from `Input` directly, so tests can script it.
- Collision layers: see `docs/architecture.md`.
- Every new mechanic gets a test in `tests/`.
- Autosprite credits are limited: log every call in `art/autosprite-ledger.csv` and spend them
  only on character animation (design bible section 13.2).

## The iteration loop

Each pass: build, run tests and screenshots, review against the bible, score the rubric
(design bible 15.3), and record it in `docs/loop/pass-NN.md`. Fix the lowest categories next.
