# Pass 428: a guardian's blow jumped with the buttons

## Category

Bosses (last pass 420).

## Audit

These guardian fights already answer the real controller:

- a whole fight from the pad to the reward (Rokusutahn, pass 404);
- a parry (King Grieve, pass 412);
- the Foreman's rock struck and pogoed (pass 420).

The parry was the only defence against a guardian's blow ever played through `Input`. No dodge was. A jump over a low blow, the oldest dodge in the genre, was never played against any guardian. Making King Grieve's sweep tall enough that no jump clears it failed none of his 253 checks.

## Fix

`test_king_grieves_sweep_is_jumped_through_the_real_controller` (test_boss) stands 62 px from King Grieve. His combo is a tall chop that reaches 54 px, then a low, wide sweep that reaches 64 px at 22 px high.

- Standing still, the chop falls short and the sweep lands.
- Jump pressed for real six frames before the sweep carries you over it, and nothing lands.
- Jump pressed once the axe is already sweeping is too late, and the sweep lands in full.

Bible 8 gains "A guardian's blow jumped with the buttons (pass 428)" after the pass 412 parry.

Mutation: a sweep 80 px high fails this test, and no other King Grieve test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. A guardian's blow is dodged with the real controller. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 429: Systems.
