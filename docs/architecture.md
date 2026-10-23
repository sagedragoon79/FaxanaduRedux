# Architecture

## Scene flow

`scenes/main.tscn` runs `scripts/game.gd`, which creates a 642x362 `SubViewport` for the
world, loads a room file into a `Room` inside it, spawns the `Player` and a `GameCamera`, and
adds the `GameHud` and `DebugHud` in the main viewport. Autoloads: `Feel` (hit-stop, shake,
rumble), `Controls` (input map built in code), `Sfx` (pooled sound player).

## Player

`scripts/player/player.gd` is a `CharacterBody2D` with hand-written movement at a fixed
60 Hz. Its origin is at the feet. Per frame: read `PlayerInput`, tick timers, wall
contact, drop-through, dash, attack, horizontal motion, jump (ground, coyote, wall, double),
jump cut, gravity, wall slide, attack hit queries, corner and ledge correction,
`move_and_slide`, landing effects and hazard checks. Attacks and hazards use immediate
shape queries (`PhysicsDirectSpaceState2D.intersect_shape`) instead of signals, so results
are deterministic within the frame.

Visuals are placeholders drawn in code (`player_visual.gd`) plus a verlet-chain scarf
(`scarf.gd`). They will be swapped for Autosprite animation without touching movement.

## Combat

- Player melee, spells and hazard checks use `Query.rect` (immediate shape queries).
- Anything with `take_hit(damage, dir)` can be hit. `dir` is the hit direction, scaled up
  for heavy hits.
- Enemies extend `scripts/enemies/enemy.gd` (health, hit flash, knockback, stagger, death,
  gold drops, respawn) and implement `_think()` as a small state machine with a telegraph
  state of at least `Enemy.MIN_TELEGRAPH` seconds. Enemy attacks call
  `hit_player_in_rect()`, which routes through `Player.receive_attack()` so parry and guard
  resolve in one place.
- Spells live in `scripts/combat/spells.gd`; each is unlocked by an `abilities` key.
- Numbers live in `CombatTuning` and are asserted by `tests/test_combat.gd`.

## Collision layers

| Bit | Value | Layer | Used by |
| --- | --- | --- | --- |
| 1 | 1 | World | Tiles, cracked blocks |
| 2 | 2 | Player | Player body |
| 3 | 4 | Hazard | Spikes, thorn bulbs (groups `hazard`, `pogo`) |
| 4 | 8 | Enemy | Enemies and dummies (groups `enemy`, `pogo`) |

Groups: `pogo` (down-strike bounces), `hazard` (hurts on touch), `breakable` (Mattock),
`room`, `player`.

## Rendering

640x360 base resolution, `canvas_items` stretch with integer scaling. The world renders in
the SubViewport with nearest filtering; the camera sits on whole pixels and the game shifts
the upscaled image by the camera's fractional remainder (`GameCamera.subpixel`), so pans are
smooth at any scale while pixels stay crisp. The camera interpolates its target between
physics ticks each rendered frame. The HUD renders at native resolution.
