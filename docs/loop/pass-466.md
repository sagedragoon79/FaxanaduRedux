# Pass 466: Executioner on a guardian, by the buttons

## Category

Bosses (last audited in pass 460).

## Audit

The first lead was per-room state that a room change rebuilds, as in pass 465's hidden-room chime.
`BossArena` keeps its fight in fields (`fighting`, `seals`, `phases_passed`), but its "already beaten"
check reads the save (`GameState.flag("boss:" + boss_id)`). So a beaten arena re-entered stays quiet,
as `test_every_beaten_guardian_stays_beaten_through_a_save` already holds. The reward banners come from
`_on_defeated` only, once per win. Nothing to fix there.

The Executioner lead was a real gap. The skill exists for guardians' openings (bible 9), but its only
test cut a Rot Dwarf that was added to the "boss" group and staggered by a call, with a scripted Attack.
No test had opened a real guardian with a parry and cut into the opening with the buttons.

## Bug found

None.

## Fix

`test_executioner_cuts_into_a_parried_guardian_by_the_buttons` (tests/test_boss.gd) fights Thane
Vorrund twice in the Throne Hall. Both runs learn the Blade branch up to the Thrust, so the two cuts
share every multiplier except one; the second run also learns Executioner. Each run uses only real input:
- Block pressed 3 steps before the chop lands parries it, and he reels.
- Right steps in, and one Attack tap cuts into the opening.

Without Executioner the cut lands plain, with no `execute` sound. With it, the same cut deals
`roundi(plain * 1.35)` and plays `execute`. Bible 9 gains "Executioner on a guardian, by the buttons
(pass 466)".

Mutation check: Executioner that never applies fails the test (10 against 10).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Score unchanged. Executioner is proved on a real guardian with the buttons. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 467: Systems.
