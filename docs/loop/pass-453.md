# Pass 453: a skill learned and unlearned with the buttons

## Category

Systems (last audited in pass 445).

## Audit

First, pass 452's lead: other ways a death or a rest could leave live state behind. The Boss Rush ends
on a killing blow and returns you to the Guru, and its shrines refuse to rest. A Guru Trial's hazards
cost time, never health, the trial rooms hold no foes, and poison never takes the last heart. Nothing
was left behind there.

The skill tree's rules were held only by calls (`Skills.learn`, `Skills.respec`) and the menu by
`open_skills` in a soak test. No skill had been learned or unlearned through the Guru's menu with the
buttons. That path includes the header rows the cursor has to skip, Jump on a learned row, and Dash to
leave.

## Bug found

None.

## Fix

`test_a_skill_is_learned_and_unlearned_with_the_buttons` (tests/test_economy.gd) presses for real at a
Guru with 3 points and 1,000 gold. Up opens his menu, and Down and Jump open Learn skills. The cursor
waits on Keen Edge, past the Blade branch's name, and Jump learns it for its point, so the blade cuts
harder at once. Jump on it again spends nothing, and Dash steps back out to play. Then Up, Down twice and
Jump on Unlearn skills forget it for the respec price: the point comes back and the blade is as it was.
Bible 9 gains "Learned and unlearned with the buttons (pass 453)".

Mutation check: a learned skill that doesn't refresh the hero's stats fails the test ("the blade cuts
harder at once (x1.00 -> x1.00)").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. The skill tree is proved with the buttons. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 454: Audio.
