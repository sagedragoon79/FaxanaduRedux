# Pass 268: King Grieve calls his household guard

Category: Bosses (last pass 260).

## Audit

I read bible 8 against each guardian's script, checking the newest pieces first:
- **The Bloom's brood:** it perishes with the Bloom (passes 263 and 266).
- **The boss rush:** it pays nothing (pass 260).
- **The rewards table:** each guardian's ring, key, blade or stat item matches its bible entry.
- **Gold:** every guardian's purse is in its zone's range.

One fight still did not match its entry. Bible 8.7's concept says King Grieve "fights with a great-axe and royal guards he summons", and its phase 2 line reads "summons crystal guards; shards fly". As built since pass 71, the throne phase calls only shards, and no guard ever came. The Shade Knights of Dartmoor are already written as "the drowned ghost of one of King Grieve's household guard" (bible 7). His guard walked the Meteor Rise behind his hall but never answered him in it, and the fight's second test, parrying, had nothing to test it while he held the throne.

## Fix

- From the throne, the first wave of shards also calls a **Shade Knight** up out of the flood with a splash (the Matriarch's `bog_rise` is hers alone, as the voices test said on the first full run). It rises at whichever end of the hall floor is farther from you: 40 px in from the west wall, or 40 px past the shards' reach.
- While it stands, no other is called. Once it falls, the second wave after calls the next, and no more than two come in a fight (`KingGrieve.GUARDS` 2, `GUARD_EVERY` 2).
- It is a room foe already on the damage sheet, at Dartmoor's threat, so pass 258's brood check holds it.
- His guard will not serve the meteor. It goes down when the meteor takes him (phase 3) and when he dies, through `Enemy.perish`, so it pays nothing (pass 266).
- Test: `test_king_grieve_calls_his_household_guard_from_the_throne` (`test_boss.gd`). It checks five things:
  - there is no guard before the first wave, and one with it, on the floor and away from you;
  - there is never a second while one stands;
  - once it is struck down from above, the next does not come with the next wave, but does with the one after;
  - the guard perishes when the meteor takes him, and pays nothing;
  - no third guard comes.
- The King Grieve soak, the brood sheet check and pass 266's perish scan all pass with it.
- Screenshot, looked at: `/mnt/project-files/pass-268/guard_780.png` shows the knight walking in along the hall floor under the rising shards. A first shot from mid-hall put him off-camera at the west wall, which is correct, since that end is the far one, so I shot it from the west end instead.
- Bible 8.7, "The household guard".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: King Grieve's fight is now what 8.7 describes. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 269 takes Systems (last pass 261).
