# Pass 418: an ordinary foe parried with the buttons

## Category

Combat and enemies (last pass 410).

## Audit

Through the real controller the fight already answers: every combat button on its frame (386), the guard held and let go on an empty floor (394), the combo windows (402), the Rune Dagger (410), and King Grieve's parry (412). What was never pressed for real was the everyday parry: the 0.12 s window against an ordinary foe, the 6 MP it pays and the stagger, and the held guard halving a blow. Those were only ever held with a scripted intent (`test_parry_staggers_and_prevents_damage`, `test_the_parry_window_is_0_12_s_and_pays_6_mp`, `test_guard_halves_damage_and_costs_mp`). The combat numbers still match bible 5.3 (their tests pass).

## Fix

- `_real_block_against_the_dwarf(frames_before, hold)` and `test_an_ordinary_foe_is_parried_through_the_real_controller` (test_combat.gd), with Block pressed through `Input` against the Rot Dwarf's swing:
  - Seen 7 steps (0.12 s) before the blade lands, it parries: the dwarf reels, no damage, at least 6 MP paid.
  - Seen 8 steps before, the whole 20-point blow lands.
  - Held from long before, it guards: no reel, the blow halved to 10, MP paid.
- Bible 5.3 gains "An ordinary foe parried with the buttons (pass 418)".

Mutation: starting the parry window two frames short fails the new test (the last parrying step falls to 5) while the scripted window test still passes. A one-frame cut is inside the window's float slack and is caught by neither.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. The everyday parry answers the real controller. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 419: World.
