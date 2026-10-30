# Pass 280: a ladder refreshes the air moves and holds no attacks

Category: Movement (last pass 272).

## Audit

I read bible 6 against `movement_tuning.gd` and the movement tests, looking hardest at the ladders. Passes 273 to 275 put the Naga over the Tower's ladders, so a climb past it is now a fight beside a ladder.

The ladder numbers are tested (`test_ladder_numbers_match_bible_6_11`), and so are these:
- climbing, hanging and stepping off the top;
- jumping off, a blow knocking you off, and the hanging ladder's end;
- a dash on the rungs;
- the camera lead.

Two rows of the 6.11 table had no test:
- **Take hold:** taking hold of a ladder refreshes the double jump and the air dash, and you can't take hold mid-swing. A climber who leaves a Naga's strike by double jumping relies on getting the double jump back on the next ladder.
- **Attacks:** there are none while climbing. A swing, throw or spell pressed on the rungs must neither fire nor drop you.

The wading row is pass 272's test, and the new guardian soaks (pass 279) fight on the arena floors, where the movement soaks already run.

## Fix

- New test `test_a_ladder_refreshes_air_moves_and_holds_no_attacks` (`test_movement.gd`). It checks three things:
  - Catching the hanging ladder from the air, with the double jump and the air dash spent, gives both back.
  - Up pressed mid-swing doesn't take hold. It does once the swing ends.
  - On the rungs, a swing, a Rune Dagger throw and a spell pressed in turn do nothing: no swing, no dagger, no mana spent and no bolt. You stay on the ladder.
- Mutation checks:
  - Without the refresh on taking hold, the test fails (false, 0).
  - Without the swing guard, it fails three ways: Up takes hold mid-swing, the next check fails with it, and a press on the rungs swings.
- No game code changed: the player already held both rows.
- Bible 6.11: a paragraph under the table.
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged score: every row of the ladder table is now tested. |
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

Pass 281 takes Faithfulness (last pass 273).
