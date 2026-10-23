# Architecture

## Scene flow

`scenes/main.tscn` runs `scripts/game.gd`, which creates a 642x362 `SubViewport` for the
world and puts a `World` in it. The UI layer (main viewport, native resolution) holds the
`GameHud` (masks, MP, potions, gold, banners, toasts), the `DialogBox`, the `MapScreen` and a
fade rectangle. The game node runs while paused; the viewport with the world does not.

Autoloads: `Feel` (hit-stop, shake, rumble), `Controls` (input map built in code), `Sfx`
(pooled sound player), `GameState` (everything persistent, plus JSON saves).

## World and rooms

`scripts/world/world.gd` owns the current `Room`, the `Player` and the `GameCamera`. It loads
rooms by id from `levels/<zone>/<room>.room`, moves the player through doors (edge doors on
touch, inner doors on Up), fades between rooms, saves at shrines, and respawns the player at
the last save after death. `build_catalog()` reads every room's header and doors for the map.
Tests register rooms in `World.texts` instead of writing files, and set `instant` to skip fades.

`GameState.data` holds abilities, max stats, gold, keys, shard counts, collected pickup ids
(`room_id:x,y`), visited rooms, world flags, the dropped gold purse and the save point.
`apply(player)` and `capture(player)` copy stats between it and the live player; the World
captures on every room change and save. The gym (`zone: gym`) ignores GameState so every
ability stays on.

Interactables (`scripts/world/interactable.gd`: shrines, tablets, inner doors, chests, later
NPCs) are in the `interactable` group. The player uses the nearest one in reach when Up is
pressed on the ground. Text goes through `GameState.say()`, `banner` and `toast` signals.

## Tiles and backgrounds

`tools/art/tilegen.py` paints each zone's tileset (`assets/tiles/<zone>.png`) and parallax
layers (`assets/bg/<zone>_far.png`, `_mid.png`) from the master palette. Ground uses 47
"blob" autotiles picked from each cell's 8 neighbours (`TilesetFactory.ground()`); wall cells
two or more tiles from open air use darker interior tiles so rooms read as space. Fake walls
(secrets) use the same tiles without collision. `Backdrop` (owned by the World) swaps the
`Parallax2D` layers when the zone changes.

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

## Reachability checker

`scripts/world/reach.gd` models where the player can stand in every room (tile columns with
three clear tiles and support below) and the moves between those spots: walking, falling with
drift, jumps inside a safe envelope, dropping through one-way platforms, doors, and climbing
wall faces with the glove. `tests/test_reachability.gd` uses it to prove the critical path
order, that every pickup is reachable, and that no spot is a soft-lock. Extend it with each
new movement ability (double jump, air dash, pogo) when that ability's zone is built.

## Data, shops and skills

Balance tables are JSON in `data/` (`items`, `shops`, `skills`, `npcs`), read through
`GameData`. `Shop` and `Skills` (`scripts/data/`) hold the buying and learning rules; the
menus (`Menus` opening a shared `ListMenu`) only display them, so tests call the rules
directly. Gear and skills turn into player numbers in one place: `GameState.refresh_stats()`.
NPCs (`scripts/world/npc.gd`) are placed with `npc:` lines and act by role: talk, king, shop
or guru.

## Bosses

A room with a `boss:` header gets a `BossArena` (`scripts/bosses/boss_arena.gd`). It seals
every door but the way in with an `ArenaSeal` (roots on the world layer), seals that one too
once the player is inside, spawns the boss, and on defeat gives the reward (ring, skill
point), sets the `boss:<id>` flag and opens the doors. Dying resets the fight because the
room is rebuilt on respawn.

Bosses are not `Enemy` subclasses: they are made of several `BossSegment` hitboxes
(`StaticBody2D` on the enemy layer, in the `enemy` and `pogo` groups) that forward hits to
the boss, which decides the damage. `Rokusutahn` moves its segments along a straight "rail"
per attack, so the body follows the head in and out of the walls. The HUD draws the health
bar of whatever is in the `boss` group, with ticks at its `PHASES` thresholds, and
`GameState.flash` gives the white flash of a boss kill; `Feel.slowmo()` the slow motion.

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
`room`, `player`, `world`, `interactable`, `purse`.

## Rendering

640x360 base resolution, `canvas_items` stretch with integer scaling. The world renders in
the SubViewport with nearest filtering; the camera sits on whole pixels and the game shifts
the upscaled image by the camera's fractional remainder (`GameCamera.subpixel`), so pans are
smooth at any scale while pixels stay crisp. The camera interpolates its target between
physics ticks each rendered frame. The HUD renders at native resolution.
