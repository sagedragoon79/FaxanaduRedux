# Pass 258: a guardian's brood answers to the sheet

Category: Combat (last pass 250).

## Audit

The damage balance sheet (bible 5.5) holds every room foe to two rows. A foe falls in 2 to 7 slashes of its zone's par blade, and no blow costs more than 1.4 masks through par armor. Every guardian and its shots are held to the guardian sheet. Pass 257 added a foe that is on neither. Pakukame's Liliths stand in no room, so `test_the_damage_balance_sheet_stays_within_its_targets` never saw them, and they aren't shots, so the guardian sheet never saw them either.

Run through the sheet, a Lilith (10 HP) fell to one slash of the Branches' par blade, the tempered Long Sword (13). That is under the sheet's floor of two, so a brood of three went down in three swings and gave the phase no pressure. The other two guardians that call foes in, the Matriarch (Marsh Hags) and the Clockwork Alpha (Clockwork Hounds), call foes that also stand in rooms, so the sheet already held them.

## Fix

- The Lilith's health is 20, two par slashes. Its blow (8, so 12 at the Branches' threat, less through Studded Mail) was already within the sheet.
- New test `test_a_guardians_brood_answers_to_the_sheet` (`test_combat.gd`):
  - It reads every guardian script for the Enemy classes it makes.
  - Each one must be one of three things: a room foe on the sheet, a guardian's shot on that guardian's row, or listed in `SUMMONED` with its zone.
  - A listed one must meet the room foe's rows in that zone.
  - It finds the Lilith, the Marsh Hag and the Clockwork Hound.
  - With the Lilith at 10 HP it fails: "Lilith in branches falls in 2 to 7 slashes of the par blade (1)".
- Bible 5.5, "A guardian's brood answers to the sheet", and the Lilith's health in 8.5.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the sheet now covers every foe a guardian calls in. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 259 takes World (last pass 251).
