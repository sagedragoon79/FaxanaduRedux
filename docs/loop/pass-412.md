# Pass 412: a guardian parried with the buttons

## Category

Bosses (last pass 404).

## Audit

- Already covered by tests:
  - Every guardian's wind-up is held to `Enemy.MIN_TELEGRAPH`.
  - Every opening in bible 8's table opens as it says.
  - Every guardian has an opening without a shield (pass 314).
  - The boss rush runs every guardian again.
  - A whole guardian fight was played with the real controller (pass 404).
- The gap is the parry. Every boss parry test called the guardian's `stagger()` itself, so a parry as a player makes it had never been played against a guardian. A player presses Block through `Input` in the moments before a blow, the blow is caught in the parry window (`Player.receive_attack`), and that throws the guardian reeling. If a guardian's blow came from a direction the parry did not count as the front, or reached the hero outside the window, every boss test would still pass.

## Fix

`test_king_grieve_is_parried_through_the_real_controller` (test_boss.gd) puts the hero, with a Small Shield, beside King Grieve and presses Block with `Input` alone:

- Pressed three frames before the axe falls, Block parries the chop. He reels open, the parry rings, and the chop does no harm.
- Pressed at the start of his 0.6 s wind-up, Block is past the 0.12 s window by the time the blow lands. It does not parry, and the raised shield guards half the chop.

Bible 8 gains "A guardian parried with the buttons (pass 412)", after pass 404's paragraph.

Mutation check: when Block opens no parry window, the test fails. King Grieve does not reel, and the hero takes the guarded half of the chop.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. A guardian is parried through the real controller. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 413: Systems.
