# Faxanadu Redux

A metroidvania remake of the NES classic *Faxanadu*, built in Godot 4.7 with HD pixel art.
The full design lives in [docs/design-bible.md](docs/design-bible.md).

## Status

**M1: movement prototype.** A graybox gym with the full movement kit: run, variable jump,
coyote time, jump buffering, wall slide and wall jump, double jump, air dash, sword slashes
and the Mattock pogo, with game-feel effects (squash and stretch, dust, hit-stop, screen
shake, camera look-ahead and synthesized sound effects).

## Running

1. Install [Godot 4.7.2](https://godotengine.org/download) (standard build, not .NET).
2. Open `project.godot` in Godot and press F5, or run `godot --path .`.

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move | Arrows / WASD | Left stick / D-pad |
| Jump | Space / Z / K | A |
| Attack (hold down in the air to pogo) | X / J | X |
| Dash | C / L / Shift | B / RB / RT |
| Drop through a platform | Down + Jump | Down + A |
| Toggle Glove, Mattock, Wing Boots, Elven Stride | F1 to F4 | |
| Reset to spawn | R / F5 | Back |
| Toggle debug HUD | F6 | |

## Tests

```bash
GODOT=/path/to/godot tools/run_tests.sh            # all tests
GODOT=/path/to/godot tools/run_tests.sh --filter=jump
```

The tests drive a scripted player and assert the movement numbers from the design bible
(jump height, apex time, coyote time, dash distance, wall-slide speed, pogo and more).
CI runs them on every push and pull request and uploads gym screenshots.

## Layout

| Path | What |
| --- | --- |
| `docs/` | Design bible, architecture notes, iteration-loop pass records |
| `scripts/` | Game code (player, world, camera, effects, UI, autoloads) |
| `levels/` | Rooms as text files (see `levels/README.md`) |
| `tests/` | Headless test suites |
| `tools/` | Test and screenshot scripts, art and audio generators |
| `assets/` | Generated and imported game assets |
| `art/` | Source art: master palette, Autosprite credit ledger |
