# Pass 279: every guardian is soaked

Category: Stability (last pass 271).

## Audit

I read bible 15.3 (Stability and performance) against what passes 272 to 278 added, then against the fight soaks in `tests/test_soak.gd`.
- **What passes 272 to 278 added is covered.**
  - The Naga lives in two Tower rooms, which the every-Tower-room soak runs with a mashing hero.
  - The new tell cues are shared sounds, already loaded at start.
  - The openings test frees each world before it builds the next.
- **The gap: six guardians had no fight soak.** Soaks covered the Widow, the Hydra, the Foreman, the Bloom, the Roc, King Grieve, Shadow Eura and the Evil One's three forms. Six had none:
  - Rokusutahn;
  - the Clockwork Alpha;
  - the Bark Knight Captain;
  - the Marsh Hag Matriarch;
  - Zoradohna;
  - the Drowned Warden.

  A lunge, web, hex, drill or wave that left an effect behind, or a frame that blew the budget in one of those fights, would have passed.

## Fix

- New test `test_every_other_guardian_fight_soak_stays_lean` (`test_soak.gd`). It fights each of the six in its arena for 20 s:
  - The hero mashes the controls and can't die, starting on the arena floor so the Alpha's drop-in shaft can't carry them out.
  - Halfway through, the guardian drops to 15% health, with one blow so that those that check their phase when hit change phase too. Its health is then held there, so the fight never ends.
  - Then the controls are let go for 4 s.
- It checks four things for each guardian:
  - the room never grows by 60 nodes or more;
  - it settles back within 6 nodes of where it started, leaving out dust and coins;
  - a frame averages under the 60 fps budget;
  - the later phase was reached.
- Rokusutahn's torn floor is meant to stay, so its spikes are counted apart and must never pass one per torn column (26).
- Measured on this machine:

  | Guardian | Peak nodes | Settled | Frame |
  | --- | --- | --- | --- |
  | Rokusutahn | 7 → 48 | 7 | 0.59 ms |
  | Clockwork Alpha | 7 → 13 | 8 | 0.54 ms |
  | Bark Knight Captain | 7 → 12 | 7 | 0.51 ms |
  | Marsh Hag Matriarch | 8 → 21 | 9 | 0.60 ms |
  | Zoradohna | 8 → 21 | 9 | 0.50 ms |
  | Drowned Warden | 8 → 12 | 9 | 0.56 ms |

  All six held, so no game code changed.
- Mutation check: with Rokusutahn's floor torn twice, the test fails on both the pile-up (74 nodes) and the stacked spikes (52).
- Bible 15.3: a new entry after pass 271's.
- No screenshot: nothing visual changed.

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
| Stability and performance | 5 | 99 | Unchanged score: every guardian fight is now soaked. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 280 takes Movement (last pass 272).
