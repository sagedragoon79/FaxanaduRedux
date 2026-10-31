# Pass 337: the Hour Glass, as the original had it and as built

Category: Faithfulness (last pass 329).

## Audit

- **The checklist.** `test_the_faithfulness_checklist_is_all_here` holds the following:
  - the eight towns' Gurus, the sixteen ranks, the four rings and the Zenis gate;
  - the key cards and the Joker;
  - the three springs, the five spells and their power deviation (pass 329), and the Red Potion deviation (pass 321);
  - the Mattock, the relics, the Dragon Slayer, and the death deviation (5.4).
- **The manual against the remake, item by item.** From the NES manual (archive.org scan):
  - **Ointment:** "For a fixed period of time the Hero will be protected from any enemy attack." The remake gives 10 s of invulnerability, the same.
  - **Glove:** "For a fixed period of time the hero's attacking power will increase." The War Glove gives x1.5 for 15 s, the same.
  - **Mattock:** "It can destroy certain special walls." The remake's Mattock breaks cracked stone and adds the pogo, which 6.6 explains.
  - **The Hour Glass** (its name is lost in the scan, between the Mattock and the Red Potion): "It can stop the movement of the enemy for a fixed period of time." The remake's glass stops only foes' shots and time-locked water, and the one clockwork family (the Hounds and the Alpha). Every other foe goes on. **No deviation note said so.** 4.1's "as built" paragraph describes the behaviour without naming what the original did. No test held that a non-clockwork foe goes on; the tests hold only what stops.
  - **Wing Boots:** the scan holds no text for them, so there is nothing to quote; 4.1 names the double jump.

## Fix

- Bible 4.1: **The Hour Glass (deviation, pass 337)** quotes the manual and says what the remake changed and why: a glass that froze every foe would be a pause button on a timer in the two hardest zones. It names the test.
- Test: `test_the_hour_glass_stops_clockwork_and_lets_other_foes_go_on` (test_enemies.gd). In stopped time a Rot Dwarf walks on and a Clockwork Hound stands still. The test also checks the bible quotes the manual.
- Mutation check: a hound that ignores the glass fails the test (it moved 46.5 px).

Nothing on screen changed, so there is no screenshot.

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
| Faithfulness | 5 | 99 | Unchanged score: the Hour Glass's change from the original is written, quoted and held. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 338 takes Combat (last pass 330).
