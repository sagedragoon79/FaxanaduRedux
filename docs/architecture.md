# Architecture

## Scene flow

`scenes/main.tscn` runs `scripts/game.gd`, which loads a room file into a `Room`, spawns
the `Player`, a `GameCamera` and the `DebugHud`. Autoloads: `Feel` (hit-stop, shake,
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

640x360 internal resolution, `viewport` stretch with integer scaling, nearest filtering,
physics interpolation on. Known gap: the camera moves in whole internal pixels, so slow pans
step visibly at high scale; the sub-pixel camera offset from design bible 12.1 is planned
for the vertical slice.
