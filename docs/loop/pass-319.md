# Pass 319: the soak wears a shield too

Category: Stability and performance (last pass 311).

## Audit

- **New tests' cost.** `test_the_rune_dagger_reaches_every_guardian` (pass 316) runs in 8 s, and the openings test in 5 s. Neither leaves state behind; the runner checks.
- **Save version 2 (pass 317).** `sanitize` reads `version` only when it is a number and treats anything else as 1. The worst case is a needless notice. A damaged file still falls back as pass 109 set up.
- **Per-frame work since pass 311.** Only Shadow Eura's `punishable()` (a state check) and the Bloodletting sound on a heal. Nothing runs every frame.
- **Soaks and the off hand.** **The soak never wore a shield.** Each room starts a new game, which has none, so the guard, the parry, the Magic Shield's reflect and the ward had never been mashed in a real room. Every soak since pass 191 threw the dagger instead. Since Sean's off-hand change the two exclude each other, so one hero can't be soaked with both.

## Fix

- `tests/test_soak.gd`: in each zone's soak, every other room wears the Magic Shield (`SOAK_SHIELD`) and the rest keep the hand free. The dagger check now counts only the free-handed rooms. A new check needs at least 10 guarded frames per shielded room.
- Bible 15.3: a paragraph after pass 191's.

First run, every zone soak: 2,085 frames guarded across 62 shielded rooms, and 612 daggers thrown in the rest. No problems, and frames averaged 0.57 to 1.11 ms.

Nothing visual changed, so there is no screenshot.

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
| Stability and performance | 5 | 99 | Unchanged score: the soaks now mash both builds. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 320 takes Movement (last pass 312).
