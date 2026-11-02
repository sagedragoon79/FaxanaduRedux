# Pass 402: the combo's windows, pressed

## Category

Combat (last pass 394).

## Audit

- Passes 386 and 394 pressed every combat button through `Input`: Block and the parry window, Spell, Next Spell, Red Potion, the Hour Glass, Throw, the Thrust, and the guard held and let go.
- Enemy telegraphs are held against `Enemy.MIN_TELEGRAPH` by the enemy suite.
- Zone threat scaling (5.5, 10.1) is held by the balance tests.
- The gap: the two windows that decide whether a second swing chains were held only with a scripted intent. These are the attack buffer (0.15 s) and the combo window (0.40 s). The combo is the hero's main attack, and its feel comes down to these frames. A press through a real pad passes through `Input` and `PlayerInput.poll`, so a window off by a frame there would have gone unnoticed.

## Fix

`test_the_combo_windows_hold_through_the_real_controller` (test_combat.gd) swings once through `Input`, then presses Attack again a set number of steps later:

- **Attack buffer:** a press in the last 9 steps (0.15 s) of the first hit's 12-step cooldown is held. Every such press swings on the same step, the one where the cooldown ends. A press one step before the buffer opens is dropped.
- **Combo window:** a press 23 steps after the swing chains into the second hit. A press at 24 steps (0.40 s) starts the combo over.

The edges come from `CombatTuning`, so a retune moves them with it.

Bible 5.3 gains "The combo's windows, pressed (pass 402)". Sean's off-hand code is untouched.

Mutation check: with the buffer set at 0.6 of its length and the combo window 0.05 s short in `player.gd`, the test fails 6 checks.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. The attack buffer and the combo window hold to the frame through the real controller. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 403: World.
