# Pass 293: a death's purse lies where you can come back to it

Category: Systems (last pass 285).

## Audit

I checked the systems (bible 9 to 12) against what passes 286 to 292 touched.
- **Refusals (pass 286).** A shop row you can't buy says why on the row: Owned, Full, Sold out, Enough, Needs shard, Needs I, or its price against the gold footer. Choosing it fizzles once (`ListMenu.confirm`). An Ointment found with a full pouch is rubbed on, or a toast says the pouch is full.
- **Drop odds and the Myconid's bread (passes 289, 290).** Nothing outside `Drop` changes the odds, so saves can't carry them. A boss rush pays nothing (pass 260). The Guru Trials hold no foes.
- **A fall out of the room (pass 291).** The game keeps no kill count, bestiary or kill quest. A fall goes through `Enemy.die` like a blow, so Wanderer's Grace refills the same way.
- **The torn-floor set-back (pass 292).** A save is made only at a shrine, and a load sets the safe spot to where you stand, so neither can restore a spot over a gap.
- **The gap was the death purse (5.4).** A death by a blow dropped 60% of your gold exactly where the blow found you. Killed in the Bloom's gap (or Rokusutahn's pit), the purse lay 12 px down in the pit. The next time the room loaded, the floor was whole again, and the purse was inside a tile. Its pickup reaches only 4 px past your body, so the gold was gone for good. The same went for a death on footing that can go, such as a Bark Knight's lance or a breaking block.

## Fix

`Player.take_damage` now leaves the purse where you fell only when you fell on the room's own floor. That means on the floor, with no hazard near, and not on footing that can go (pass 288). Otherwise the purse goes on the last safe ground you stood on (`safe_position`), as a hazard death already did.

Test: `test_a_death_in_a_torn_pit_leaves_the_purse_beside_it` (`test_boss.gd`). The Bloom tears the leaf under you, and a blow kills you as you drop into the gap. The purse must lie on the leaf beside the gap. Without the fix it lay at (660, 332), in the pit.

Bible 5.4: the death row and a paragraph.

No screenshot: the purse looks the same; only where it lies changed. The test checks it.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: a death's purse can no longer be buried in a floor. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 294 takes Audio (last pass 286).
