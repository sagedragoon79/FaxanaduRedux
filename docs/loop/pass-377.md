# Pass 377: whose is it (Faithfulness)

Category: Faithfulness (last pass 369).

## Audit

Passes 370 to 376 added three Sunken Spring landmarks, the minimap, the fall's sound and tests for reveals and swimming. None of them changed a name, item, price or story beat from the original.

The audit found one claim that was false, in 5.2: "The other nine (... Battle Suit ...) keep their names and their place." The remake's Battle Suit is won from the Drowned Warden (8.10, `BossArena.BOSSES` `drowned_warden` gives `armor: battle_suit`). The Warden lives in the Sunken Spring. The original had neither that guardian nor that zone, so the suit cannot be in the original's place. The deviation was real but not recorded.

Behind it was a wider gap. The bible never said in one place which zones and guardians are the original's and which are the remake's own. The 3.2 table marks the Sunken Spring and the Trials "opt". Section 8 lists the Foreman, the Bark Knight Captain, the Marsh Hag Matriarch and the Clockwork Alpha beside the original's nine with nothing to set them apart. A guardian added later could go unrecorded the same way.

## Fix

- Bible 3.2 has a new ledger, "Whose is it (pass 377)":
  - Every zone in `World.ZONES` is marked as the original's (eight) or the remake's own (the Sunken Spring and the Guru Trials).
  - Every guardian in `BossArena.BOSSES` is marked as the original's (nine, with the Evil One's avatar, veins and heart as one) or the remake's own (five).
  - It gives each guardian's prize. Where a guardian of the remake's own hands over one of the original's things (the Foreman's Mattock, the Warden's Battle Suit), its row says the thing is moved.
- Bible 5.2: the Battle Suit is taken out of the gear that keeps its place, and its line is now a recorded deviation (pass 377).
- `test_the_bible_says_whose_each_zone_and_guardian_is` (`test_rooms.gd`) checks:
  - every zone and guardian has a row;
  - the original's are exactly the eight zones and the nine guardians;
  - each named prize matches the code's reward;
  - no gear won from a guardian of the remake's own is listed in 5.2 as keeping the original's place.

Mutation checks:
- With the Battle Suit put back in 5.2's kept list, the test fails 1 check.
- With the Foreman marked as the original's, it fails 2 checks.

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
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score. Every zone and guardian is marked as the original's or the remake's own, and the Battle Suit's move is recorded. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 378: Combat.
