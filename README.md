# Faxanadu Redux

A metroidvania remake of the NES classic *Faxanadu*, built in Godot 4.7 with HD pixel art.
The full design lives in [docs/design-bible.md](docs/design-bible.md).

## Status

**M3: vertical slice, in progress.** A title menu starts a new game at the West Gate of
Eolis. Six Eolis rooms (King, Guru, shops, townsfolk) and nine Trunk Hollows rooms (sap
pools, Monodrons, Hornets, Rot Dwarves, the Climbing Glove, secrets, save shrines) are
connected by doors, with a map, saving, ranks, a skill tree, shops and Jack doors. The
Rokusutahn boss, final art and music come next. The movement and combat gym is still there:
`godot --path . -- --room=gym/gym`.

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
| Talk, read, use doors, rest at shrines | Up | Up |
| Map | Tab / M | Back |
| Toggle Glove, Mattock, Wing Boots, Elven Stride, Deluge (debug builds) | F1 to F4, F7 | |
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
