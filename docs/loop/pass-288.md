# Pass 288: a spike never sets you back onto footing that is gone

Category: Movement (last pass 280).

## Audit

I read bible 6 and `movement_tuning.gd` against the tests, and looked at what passes 281 to 287 touched.
- **Every `MovementTuning` value is named in a test.**
- **The empty-flask press (pass 286) interrupts nothing.** It plays its sound and returns before the drink, and a drink never starts without a charge.
- **The coins and drops kept in their rooms (passes 283 to 287)** never touch the player's body.
- **The gap is the spike set-back (5.3, pass 282).** The test arena checked it on plain floor. The rule for safe ground is: you are on the floor, and no hazard is near. The only footing it refused was stilled water (pass 162). But the floor can also be:
  - a cracked block;
  - a Bark Knight's or the Captain's rooted lance;
  - a crystal shard;
  - a gate or a raft.

  All of these can go. I stood on a cracked block over a row of spikes and broke it. You fall onto the spikes and are set back into the air where the block was, then onto the spikes again. **That cost four masks in three seconds, and the loop would have run until you died.** Bible 6 never said where a set-back lands.

## Fix

- `Player._on_fleeting_ground` replaces `_on_stilled_water`. Any floor that is not the room's own tiles (`TileMapLayer`) is never kept as the safe spot. Stilled water is still refused, now by the same rule.
- Test: `test_a_spike_never_sets_you_back_onto_footing_that_is_gone` (`test_combat.gd`). You stand on a cracked block over spikes, then it breaks under you. Within 3 s:
  - the spikes have cost exactly one mask;
  - you stand on the floor where you last stood before the block.

  Before the fix it fails: 80 HP lost, and you are still on the spikes.
- The stilled-water test (pass 162) still passes under the new rule.
- Bible 6.13 "Set back", new: where a set-back lands, and why footing that can go does not count.
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: a set-back can no longer land in the air over the spikes it came from. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 289 takes Faithfulness (last pass 281).
