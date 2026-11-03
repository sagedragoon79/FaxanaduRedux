# Pass 414: the ready chimes, on time

## Category

Audio (last pass 406).

## Audit

- The mix is clean. `tools/audio/levels.py --check` reports 166 sound effects (median -18.5 dB), 34 music tracks and 14 ambience beds, with no clipping and no stray levels.
- The sounds from passes 407 to 413 are already heard by tests of their own:
  - the shop's coin and `menu_refuse` (pass 413);
  - the parry against King Grieve (pass 412);
  - the key door's `door_locked` and `key_turn`;
  - the dagger's throw and its wall ping;
  - the save chime (pass 406).
- The guardians' wind-ups are held by `test_every_guardian_tell_is_heard_as_it_starts`.
- I listed every sound file that no test names by name. Most are covered another way: by a constant (`GUARD_BREAK_SOUND`, `GLASS_TICK_SOUND`), by the tell scans, or by the footstep tests.
- The gap is the two ready chimes, which tell a player that a move is ready again without looking:
  - `thrust_ready`, when Attack held fills the Thrust's charge;
  - `dagger_return`, as the Rune Dagger reforms at your hip, a chime the bible's Rune Dagger section promises.
- Only the "every sound heard" gate held these two. A chime early, late, twice or not at all would have passed.

## Fix

`test_the_ready_chimes_ring_when_the_move_is_ready` (test_combat.gd) presses the real controller:

- Attack held chimes once, on the frame the 0.4 s charge fills.
- A dagger thrown at the wall chimes once, as it is back and ready to throw.

Bible 13.3 gains "The ready chimes, on time (pass 414)".

Mutation check: the Thrust's chime was moved to half charge and the dagger's chime was silenced. The test failed both checks: "on the frame the charge fills (0.217 s of 0.40)" and "the Rune Dagger chimes once (0)".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. The two ready chimes are heard once, on time. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 415: Stability.
