# Pass 394: the guard, held through the real controller (Combat)

Category: Combat and enemies (last pass 386).

## Audit

- Passes 387 to 393 changed no combat number. Every value in `combat_tuning.gd` is written in 5.3 and held by `test_every_combat_number_is_written_in_bible_5_3`.
- The Windloft veil (388) touches no fight. The rename list's foes (393) are names only.
- Pass 386 timed every combat button's press through `Input`, and the Thrust's release. The guard is the other held button: `Player._update_block` raises the shield from `block_held`, and mends a broken guard (pass 242) only once Block is let go. Every test of the guard scripted that intent, so a guard that read Block as a press, or a break that never mended, would have passed.

## Fix

`test_the_guard_stands_while_block_is_held` (`test_combat.gd`) holds Block through `Input`:
- the guard stands past the parry window for as long as Block is down;
- let go, it drops in the step the release lands in;
- pressed again, it is back up;
- broken, it stays down while Block is still held;
- letting go mends it, and the next press raises the shield.

Bible 5.3 gains "The guard, held (pass 394)", and the test checks 5.3 names it.

Mutation checks:
- `block_held` read as just pressed: 1 check fails (the guard past the parry window).
- The mend on release removed: 2 checks fail.

Full suite: 7100 checks passed, soaks 50.5 minutes, every sound heard.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. The guard is held and let go through the real controller. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 395: World.
