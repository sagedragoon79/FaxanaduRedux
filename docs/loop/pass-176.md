# Pass 176: the Captain's bough as footing

Every category apart from Art was tied at 99. Movement weighs the most (20), so pass 176 takes Movement. I audited movement against bible 6 and the newest content (passes 169 to 175).

| Check | Finding | Verdict |
| --- | --- | --- |
| Bible 6 numbers | `movement_tuning.gd` and the movement tests still match bible 6 | fine |
| The Proving Scar (pass 170) | `test_the_proving_scar_asks_for_every_ability` holds: every ability is needed, and nothing is reachable early | fine |
| Clockwork Alpha (pass 169) | foes don't body-block the player (enemies collide only with the world), so a charge can't pin you to the den's wall; the pounce and charge are cleared by a jump, as tested in pass 169 | fine |
| Forepaw's physician and larder (pass 175) | town NPCs on the floor; nothing to move around | fine |
| **The Captain's bough (pass 171)** | The bible promises a rooted lance you can stand on or pogo off. The Bark Knight's lance had tests for landing, drop-through and coyote time (pass 110), but the Captain's bough was only checked as "solid". Nothing proved you could land on it, drop through it, pogo off it, or get a fair jump when he pulls it from under you. | **built** |

## As built

- `test_the_captains_bough_holds_your_weight_until_he_pulls_free` (new), with the Captain held rooted. It checks that you can:
  - land on the bough and stand on its top;
  - drop through it with Down + Jump to the floor;
  - pogo off it with the Mattock (a down-strike bounces you up past 300 px/s);
  - stand on it again and, once he pulls it free, still jump 4 frames later on coyote time;
  - land on the floor afterwards, never caught inside the bough.
- All of it passed on the first run, so no game code changed. The bible's Captain entry now records the promise and its test.

## Tests

- `test_boss.gd`, `test_the_captains_bough_holds_your_weight_until_he_pulls_free` (new).

Full suite: 3308 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged: the audit found the bough sound, and it is now tested. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Every category apart from Art is still at 99. Ties break by weight, then by the oldest last pass, so pass 177 takes Combat (weight 15, last pass 169).
