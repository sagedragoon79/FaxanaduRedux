# Pass 452: a fight lost beside its own shrine starts over

## Category

Bosses (last audited in pass 444).

## Audit

Pass 449 proved a death raises you at your last rest. The world builds the room you rise in afresh,
but only when it is not the room you died in. One guardian's room has a rest inside it: the Zenis Gate,
Shadow Eura's arena, has a Meditation Shrine by the way in. A probe rested there, woke Eura, wounded her
to 40% and fell.

## Bug found

The hero rose beside the shrine with both doors still sealed and Eura still up at 128 of 320 HP, her
music still a step higher. The fight could be worn down one death at a time, and the rise could land
in the middle of her swing.

## Fix

`World._respawn_player` now builds the room afresh when a guardian's fight is going on in it
(`_fight_under_way`), as it does whenever you rise in another room. The guardian is gone, the way in is
open, the zone's music plays as written, and walking in wakes her again whole.
`test_a_fight_lost_beside_its_own_shrine_starts_over` (tests/test_boss.gd) rests at the shrine by the
real Up, walks in by the real Right, wounds her past her marks, falls, and walks in again. Bible 8 gains
"A fight lost beside its own shrine starts over (pass 452)".

Mutation check: without the fix, five checks fail (Eura still waits, both doors sealed, her music
still lifted, and she wakes at 128 of 320).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. A lost fight beside its own shrine starts over. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 453: Systems.
