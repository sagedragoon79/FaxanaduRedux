# Pass 271: the King Grieve soak calls his guard

Category: Stability and performance (last pass 263).

## Audit

I checked what passes 264 to 270 added against the soaks and leak checks in bible 15.3:
- Wade spray (264) is plain Dust, freed when its life ends. The room soaks walk Dartmoor's tide halls, so it is covered.
- The Mascon tavern NPCs (265) are talk NPCs, and the Mist room soak and the door walk load Mascon.
- `Enemy.perish` (266) runs through `die()`, and the Bloom soak (263) already fells the Bloom with its brood in the air.
- The `[boss:id]` sign lines (267) are plain text on a tablet, and their own test reads every one.
- The Inventory groups (269) are menu rows drawn from GameState. The HUD and menu tests cover drawing them.
- `Sfx.LIFT` (270) only adds a constant to a volume.

The gap was King Grieve's household guard (268). His soak, `test_king_grieve_fight_soak_stays_lean`, was written before the guard existed. It checked duels, the ward and shard waves, but never looked for a knight. A guard that piled up, came more than `GUARDS` (2) times, or outlived him would pass. The Bloom's brood has had that check since pass 263.

## Fix

`test_king_grieve_fight_soak_stays_lean` (test_soak) now:
- counts every living Shade Knight in the hall each frame of the 30 s fight. The guard must come at least once, every knight seen must be one he called, no more than one may stand at a time, and he may call no more than `GUARDS`.
- fells him with a knight still standing. The soak checks one does: with seed 71 the guard is up when he falls. None of the guard may be left 4 s later, and the hall must be back within 20 nodes of where it began.

The fall starts a slow motion timed on the wall clock (`Feel.boss_kill`), and a headless run gets through 240 frames before that clock has moved much. So 43 dust motes were still in the air when the hall was counted. The soak ends the slow motion with `Feel.reset()` first. This is an artifact of the test, not a leak: in a real game the slow motion ends in about a second.

Mutation check: with `_dismiss_guard()` taken out of `KingGrieve.die()`, the soak fails ("no knight of his guard outlives him (1, one stood at his fall: true)").

Bible 15.3 has a new entry, "The King Grieve soak calls his guard", after the Bloom soak's.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score: the King's guard is now soaked. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 272 takes Movement (last pass 264).
