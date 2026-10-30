# Pass 292: a torn floor never sets you back over the gap

Category: Bosses (last pass 284).

## Audit

I checked the guardians (bible 8) against what passes 285 to 291 touched.
- **Purses (passes 285, 287).** Every arena adds its guardian to the room itself (`BossArena`, `room.add_child(boss)`). So a guardian's gold and drop are sprayed into the room and go through `Drop.keep_in_room` like any foe's. A probe that felled each guardian saw the purses leave the guardian's body inside the arena.
- **Sure drops and odds (passes 289, 290).** No guardian sets `sure_drop`. A brood that dies with its guardian still `perish`es and pays nothing (pass 266).
- **A fall out of the room (pass 291).** Guardians are left out of `Enemy._fall_out_of_room`. The Liliths fly. The daughters and hounds walk arenas with whole floors, so none can fall out.
- **The spike set-back (pass 288).** The Captain's lance and Zorugeriru's crystal are not tiles, so they were already never a safe spot. **The gap was the Bloom's leaf.** In phase 2 every other bite tears a four-tile chunk out of the leaf where it lands (8.5), with thorns below, and it lands where you stand. Your safe spot was the tile you stood on, which is now the gap. So the thorns set you back over the gap, you fell onto them again, and **one bite cost five masks and killed you** (100 HP gone in the test). Rokusutahn's pit moves the spot itself; the Bloom never did.

## Fix

Two things now keep the spot off a torn floor:
- `Room.tear_floor` moves a safe spot that sits over the torn columns to the nearer solid tile beside the pit (`_keep_set_back_off`). This covers the Bloom's leaf and Rokusutahn's pit.
- `Player._on_fleeting_ground` treats a tile that has been erased as gone. The layer's collision lingers for a frame after the cells go, and in that frame you stood on it and took the spot back.

Test: `test_a_torn_floor_never_sets_you_back_over_the_gap` (`test_boss.gd`). The Bloom tears the leaf under you on each side of its root. The thorns must cost one mask, and set you on the leaf beside the gap.

Mutation check: with either half taken out, the test fails. Without the room's move the player dies (100 HP lost). Without the player's check, the spot is taken back the next frame.

Bible: 6.13 has a paragraph and 8.5 phase 2 has a sentence.

No screenshot: nothing on screen changes, only where a set-back lands. The test checks it.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: a bite of the Bloom can no longer kill through a set-back loop. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 293 takes Systems (last pass 285).
