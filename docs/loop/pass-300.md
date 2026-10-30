# Pass 300: a purse on torn floor moves beside the pit

Category: Bosses (last pass 292).

## Audit

I checked the bosses (bible 8, telegraphs, zone threat 5.5) against what passes 293 to 299 touched.
- **The purse in a torn arena (pass 293).** A death in the Bloom's gap or Rokusutahn's pit leaves the purse on the last safe ground. That spot is inside the sealed arena. On a respawn the room loads whole and the fight starts again, so the purse is there to take back. **But a purse left on the floor that a later bite tears away stays where it was, hanging over the new pit.** The purse floats and has no gravity. To take it back you had to drop past it into the thorns, which costs a mask and a set-back. In the Bloom's fight that can happen on any part of the leaf away from the root and the walls. In Rokusutahn's fight it happens on the middle of the floor, which tears in phase 2.
- **The set-back in a fight (pass 296).** Only spikes and thorn bulbs are hazards, and in the arenas they are the thorns under a torn floor. A set-back puts you on the tile beside the pit (pass 292), or on the side of the floor that Rokusutahn picks. It gives 0.8 s of invulnerability and no control lock. You can act at once, and nothing a boss swings lands during those 0.8 s.
- **Summons that fall (pass 298).** Pakukame's brood (Liliths) fly. King Grieve's Shade Knight walks a throne hall with no gap in its floor. Both bosses count only the summons still alive (`not dead`), and a foe that falls out is dead, so neither boss can stall on one. Summons never respawn (`respawn_time` 0), so a fallen one is freed.
- **The PixelLab hero against the arenas.** Screenshots of the Sunken Chapel, the Throne Hall, the Root Chamber and Zenis's throne are in `/mnt/project-files/pass-300/`. His purple hair and green coat stand out against the Mist's grey, Dartmoor's blue stone and the Trunk's bark. Against Zenis's violet he is the weakest of the four, but he is still clear. This is an art matter, which is deferred.

## Fix

- `Room._keep_set_back_off` moves every purse lying over the torn columns to the nearer tile beside the pit, with the set-back spot, and updates the saved purse (`GameState.data.purse`), so a reload puts it there too. The side-of-pit search is now `Room._beside_pit`, which both moves share.
- Test: `test_a_purse_on_torn_leaf_moves_beside_the_gap` (`test_boss.gd`). A purse lies on the Bloom's leaf, and a bite tears the leaf under it. The purse must end up beside the gap, on the leaf, with the save matching. Standing there must take it back without a hurt. With the purse loop taken out, the test fails: the purse stays over the gap.
- Bible 5.4: a sentence after pass 293's note.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: a purse left in a torn arena can be taken back without a hurt. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 301 takes Systems (last pass 293).
