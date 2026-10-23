# Faxanadu Redux

A metroidvania remake of the NES classic *Faxanadu*, built in Godot 4.7 with HD pixel art.
The full design lives in [docs/design-bible.md](docs/design-bible.md).

## Status

**M2: combat core.** A graybox gym with the full movement kit (run, variable jump, coyote
time, jump buffering, wall slide and wall jump, double jump, air dash, the Mattock pogo) and
combat: a three-hit combo, parry and guard with the shield, the Deluge spell, the Red Potion,
three enemies (Monodron, Hornet, Rot Dwarf), gold drops and a death and recovery loop.
Game feel: squash and stretch, dust, hit-stop, screen shake, sub-pixel smooth camera and
synthesized sound effects.

## Running

1. Install [Godot 4.7.2](https://godotengine.org/download) (standard build, not .NET).
2. Open `project.godot` in Godot and press F5, or run `godot --path .`.

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move | Arrows / WASD | Left stick / D-pad |
| Jump | Space / Z / K | A |
| Attack (hold down in the air to pogo) | X / J | X |
| Dash | C / L / Shift | B / RB / RT |
| Block (tap to parry) | V / I | LB |
| Cast spell (Deluge) | F / U | Y |
| Drink Red Potion | Q / H | LT |
| Drop through a platform | Down + Jump | Down + A |
| Toggle Glove, Mattock, Wing Boots, Elven Stride, Deluge | F1 to F4, F7 | |
| Reset to spawn | R / F5 | Back |
| Toggle debug HUD | F6 | |

## Tests

```bash
GODOT=/path/to/godot tools/run_tests.sh            # all tests
GODOT=/path/to/godot tools/run_tests.sh --filter=jump
```

The tests drive a scripted player and assert the numbers from the design bible (jump
height, coyote time, dash distance, combo damage, parry, guard, potion, spells, enemy
telegraphs and more), plus a random-input soak run through the gym.
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
