# Pass 495: A rested spot now walled over wakes you safe

## Category

Stability and performance (the next rubric category in the rotation). No new workbench notes; the
headline queue item, the PixelLab art pass for the seven placeholder guardians, is still blocked —
`PIXELLAB_API_KEY` is set in no scope on this PC — so this pass takes the next non-art item, a load-path
robustness fix that needs no generations.

## Audit

Followed the save/load resilience leads a survey turned up. `GameState.load_game` and `sanitize` are
thoroughly defended (a damaged file falls back to its `.bak`; every key is coerced to its type; numbers
are clamped; unknown ids play as none — all soaked and unit-tested, bible 15.3). The boot path handles a
**missing** `save_room`: `game.gd._continue` checks `World.room_exists` and, if the room is gone, wakes
the hero at the new-game spot (`NEW_GAME_ROOM`, bible 15.3).

The gap was the case next to it: a room this build **still has**, but whose shape has changed since the
save was written (or a hand-edited save), so the spot you rested on is now inside solid tiles.
`World.start(room_id, at)` teleports the hero straight to the restored position with no open-ground
check, and the only spawn-time rescue in `_physics_process` is the fall-rescue — it catches a drop past
the floor (`FALL_RESCUE`), not a spawn embedded in a wall. So an old save pointing at a valid room id
with a stale position would wake the hero embedded in solid.

## Bug found

A soft-lock, not a crash. Load a save whose `save_room` exists but whose `save_pos` now sits in solid
and the hero wakes inside the wall: no rescue frees him (the fall-rescue only fires below the floor), so
he is stuck. Proved by the mutation check below — with the new guard disabled, the hero wakes at the
walled-over spot `(344, 120)` instead of the room's spawn.

## Fix

`scripts/world/world.gd`:

- **`World.start`** now checks a restored position before committing to it. When `at` is a real position
  (not `Vector2.INF`, the new-game sentinel) and the hero's body there would sit in solid, it falls back
  to the room's own spawn, as if arriving fresh — the same path a new game takes, so a room with no
  spawn marker still arrives through its first door. A new game (`at == INF`) is untouched; its spawn is
  safe by design.
- **`World._embedded_at(pos)`** is the shared test: it draws "embedded" exactly as the soak's `_embedded`
  does — the body grown in 3 px, its four corners and centre, against `room.is_solid_at` — so the code
  and the test agree on what embedded means (the pass-494 pattern of sharing geometry).

The missing-room fallback (`game.gd`) is unchanged and still handles a room that is gone entirely; this
closes the sibling case of a room that stayed but moved its floor.

## Test

`test_a_restored_position_in_solid_wakes_at_the_spawn` (in `tests/test_world.gd`): a room with a spawn
marker on its floor and a solid block walled through its middle. Loaded with a restored position deep
inside the block, the hero wakes at the room's spawn, his body clear of solid, and after 30 frames stands
safely at full health and can play on. Loaded with a still-valid floor position, that position is kept —
the guard never relocates a good restore. Mutation check: disabling the guard
(`if false and at != Vector2.INF and _embedded_at(pos)`) fails 3 checks (the hero wakes at `(344, 120)`
in the wall, his body is not clear, and he does not stand safely). The design bible's resilience list
(15.3) gains the "A rested spot now walled over" bullet beside "Missing rooms".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 85.25 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Score held. A load onto a walled-over rest spot no longer wakes the hero embedded in solid. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8875.

## Next

Pass 496: Story and world (the next rubric category in the rotation). The art loop's guardian pass stays
blocked until `PIXELLAB_API_KEY` is set on this PC and the app is restarted.
