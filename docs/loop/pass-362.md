# Pass 362: how far a swing reaches (Combat)

Category: Combat (last pass 354).

## Audit

Passes 355 to 361 changed no combat number. The boss kill flash (356) and the squash shapes (360) are held by their own tests, and the tuning tables (5.3, `test_every_combat_number_is_written_in_bible_5_3`) still match.

Next I checked the constants in `player.gd` that act in a fight against the bible and the tests. The poison, Bloodletting, Last Stand and Time Thief numbers each have a test. The most basic number in a fight had neither a line nor a test: how far a swing reaches.
- `Player.SLASH_SIZE` (36x26), `UP_SLASH_SIZE` (34x36) and `THRUST_LENGTH` (52) set every hit box. No line of 5.3 gave them.
- Bible 5.2 gave the reach of the Broad Sword and the Dragon Slayer, but not of the Short Sword (0) or the Long Sword (8). It never gave the Broad Sword's arc (20).
- The only test of any swing's size was relative: the Broad Sword's box is 16 px longer and 20 px taller. Grow every box by the same amount and nothing would fail.

Every foe's spacing and every telegraph distance is set against this reach, so it is the number a combat audit most needs to read.

## Fix

- Bible 5.3: a **Swing reach** row. A slash reaches from inside the body to 34 px past its front edge, 26 px tall. An up-slash is 34 by 36 and reaches 32 px over the head. A Thrust is 52 px long and 13 tall. A blade's reach and arc add to the slash and the Thrust. The down-strike is 6.6's 28x24.
- Bible 5.3 also gains a note, "How far a swing reaches (pass 362)".
- Bible 5.2: every blade's reach (Short Sword 0, Long Sword 8), and the Broad Sword's arc.
- `test_every_swing_reaches_as_far_as_5_3_says`:
  - holds each blade's reach and arc to 5.2;
  - measures the real hit box of a slash, an up-slash and a Thrust with each of the four blades against the row;
  - swings the Short Sword at a training dummy 2 px inside the edge (struck) and 2 px past it (missed).

Mutations: a slash box of 40 px fails 5 checks, and a Thrust of 60 px fails 4.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. The swing's reach is written and held. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 363 takes World (last pass 355).
