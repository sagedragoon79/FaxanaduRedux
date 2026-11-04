# Pass 455: no rest while a guardian stands

## Category

Stability (last audited in pass 447).

## Audit

Pass 452 found that the Zenis Gate is the one guardian's room with a rest inside it. This pass went
through every room with a shrine or a Guru for other live state (a boss, a seal, a lift, foes) and
probed the risky ones:

- Five shrine rooms with foes that chase (fliers and ghosts): rest, wait, fall, rise. Four left the
  hero alone. In the Drift Well a Lantern Ghost reached a hero standing still at the shrine, but it did
  so just the same when the room was built afresh. That is the ghost's design (it drifts through walls),
  not live state left behind.
- Then a rest in the middle of Shadow Eura's fight.

## Bug found

Up at the Zenis Gate's shrine with Eura up made the hero whole, refilled his magic and flask, and saved,
as often as he liked. A guardian fight could be won by resting at one end of the room.

## Fix

A shrine now refuses while any guardian's fight is going on (`BossArena.any_fighting`), as it already
did in the boss rush. It plays `menu_refuse`, says "The shrine is silent while the guardian stands.", and
mends and saves nothing. Before the fight, and once the doors open again, it rests as any shrine does.
`test_no_rest_while_a_guardian_stands` (tests/test_boss.gd) presses the real Up there before, during
and after. Bible 8 gains "No rest while a guardian stands (pass 455)".

Mutation check: with the refusal turned off, four checks fail (100 HP and 60 MP restored, a save made,
the `save` chime heard, "Rested. Progress saved." said).

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
| Stability and performance | 5 | 99 | Score unchanged. An exploit closed. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 456: Movement.
