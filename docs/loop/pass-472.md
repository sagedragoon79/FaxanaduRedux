# Pass 472: Combat at every game speed

## Category

Combat.

## Audit

Pass 470 found that the dash's timer cut its stride at 70% game speed, and combat's timers had never
run at any speed but 100%. A probe pressed the real buttons at 100, 90, 80 and 70%. It covered the
parry window (`parry_window`, 0.12 s), a slash's cutting time (`slash_active`, 0.10 s) and the Thrust's
lunge (`thrust_speed` 320 px/s for `thrust_time` 0.16 s, about 51 px).

| Speed | Parry, frames (game time) | Slash, frames (game time) | Thrust lunge |
| --- | --- | --- | --- |
| 100% | 8 (0.133 s) | 6 (0.100 s) | 53.3 px |
| 90% | 8 (0.120 s) | 6 (0.090 s) | 52.8 px |
| 80% | 9 (0.120 s) | 7 (0.093 s) | 51.2 px |
| 70% | 11 (0.128 s) | 8 (0.093 s) | 52.3 px |

Each timer can end up to one step either side of its game time, as every fixed-step timer does. Game
speed is an assist, so what matters is the window a player meets on screen. Counted in frames, every
window only grows as the game slows, and the Thrust reaches at least its stated length at every speed.
The dash had been different, because its short stride decided whether a gap could be crossed.

## Bug found

None. A proof.

## Fix

`test_combat_windows_only_widen_as_the_game_slows` presses real Block, Attack and a held-and-let-go
Attack (the Thrust) at each of `Settings.SPEED_STEPS`. It checks three things: the parry and slash
windows never shrink in frames as the speed drops; each stays within one step of its game time; and the
lunge carries between 51.2 px and one step beyond. Bible 5.3 gains "Combat at every game speed
(pass 472)".

Mutation check: a parry timer that ticks by a whole frame (not the scaled step) fails the test at 70%
(0.093 s of 0.12).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. Combat's windows are proved at every game speed. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 473: World.
