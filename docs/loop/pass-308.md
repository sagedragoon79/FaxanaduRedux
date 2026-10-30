# Pass 308: no drop rests on spikes

Category: Bosses (last pass 300).

## Audit

I checked the guardians (bible 8) against what passes 301 to 307 touched.
- **Drops in arenas (passes 300, 307).** An arena's doors are sealed by `ArenaSeal` bodies on the world layer, so a drop or coin bumps the seal and can't get into the doorway. Pass 307's clamp keeps drops two tiles in either way. A guardian's own gold is sprayed when it dies, after the seals open, and the magnet draws coins out of any pit. **But the Bloom's Liliths die mid-fight and roll a drop like any foe:** bread, a mana orb, or 1 time in 40 a War Glove or an Ointment. One struck down over a torn leaf dropped it into the thorns, and bread lying on the leaf when it tore fell in too. Pass 300 moved only the purse. Taking a drop out of the pit cost a blow, and with the old code a War Glove dropped into the Bloom's tear stayed on the spikes (the new test, run without the fix: both drops in the pit, 21 health lost taking them). Rokusutahn calls no foes, so only a purse can lie on his floor, and pass 300 moves it.
- **Poison in guardian fights (pass 306).** No guardian or add drops poison. `poison_drops` is set by the four poison species and by corruption, which only room spawns get, and guardians' adds are spawned by the guardian.
- **Arriving into a live fight (passes 299, 304).** The Alpha's Den is entered down a floor door, and every boss room's floor and ceiling doors are in the door soak, which fails on any hurt during the ride and the landing. None hurts.
- **Quickened tells.** `test_every_wind_up_in_the_game_is_fair` still holds every guardian's named wind-up and phase-quickened tell to `Enemy.MIN_TELEGRAPH`. Nothing in passes 301 to 307 changed a tell.

## Fix

- `Drop._step_off_spikes`: a drop that comes to rest on spikes (a torn pit's or a level's) moves to the nearest floor beside them, at most `Drop.SPIKE_STEP_RISE` (4) tiles up the pit's side.
- Test: `test_a_drop_never_rests_in_the_thorns` (`test_boss.gd`) tears the Bloom's leaf under bread and drops a War Glove into the pit. Both must rest on the leaf beside it, and taking them must cost nothing. Without the fix it fails six checks.
- Bible 10.1: a paragraph after pass 307's.

No screenshot: a drop rests a tile or two to the side, which a still frame wouldn't show.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: a Lilith's drop is never a trap. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 309 takes Systems (last pass 301).
