# Pass 378: what a foe pays (Combat)

Category: Combat (last pass 370).

## Audit

Passes 371 to 377 changed no foe, blow or spell. They covered landmarks, reveal tests, the minimap, the fall's sound, swimming tests and the whose-is-it ledger. So the audit looked at what the bible still doesn't hold about the foes.

Pass 338's numbers table in 7 gives every foe's health, touch, wind-up and main blow, and its test holds each one to the script. It said nothing about what a foe pays. Each script's purse (`gold_min`, `gold_max`) and experience (`xp`) lived only in code. Two systems are built on them:

- the gold sheet (10.1), whose zone ranges are these purses times the zone's threat;
- the ranks (9), whose thresholds assume what a kill gives.

All 9 said was "Starting enemies give 5 XP (Rot Dwarf 12)", and nothing held even that. The table also didn't say that experience, unlike gold, is not scaled by the zone's threat. A change to either would have passed unseen.

## Fix

- Bible 7's numbers table has two new columns, Gold and XP, for all 25 foes, taken from the scripts.
- A new note, "What a foe pays (pass 378)", says the following:
  - gold is multiplied by the zone's threat as the foe dies;
  - experience is not;
  - corruption doubles both.
- `test_every_foes_numbers_are_written_in_bible_7` now checks:
  - both new columns against each script;
  - 9's line on the first foes' experience against the Monodron and the Rot Dwarf;
  - six real kills of a Monodron in a Dartmoor room (threat 2): each adds exactly its 5 XP and sprays 6 to 12 gold.

Mutation checks:
- With the Spring Eel's experience at 15, the test fails 1 check.
- With `Enemy.die` scaling experience by the threat, every real kill fails (got 10, not 5).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. What every foe pays, in gold and experience, is written and held. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 379: World.
