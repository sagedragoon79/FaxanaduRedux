# Pass 480: Thrown and cast at every game speed

## Category

Combat.

## Audit

Leads: the Rune Dagger and the spells under a slower game, hitstop stacking, and a hit on the frame the
hero is frozen.

- Hitstop does not stack: `Feel.hitstop` keeps the later of two end times, so a slash that kills two
  foes freezes for one kill's 80 ms, not two. A hitstop inside a slow motion hands back the slow scale.
- A blow during a sign or a door is covered (passes 435, 436 and 439).
- The dagger and the spells had been thrown and cast only at full speed. Each projectile moves by
  `speed * delta` and counts its reach or life in game time, so its reach should hold at every speed. A
  probe with the real buttons agreed.

## Bug found

None. A proof.

## Fix

`test_thrown_and_cast_reach_holds_at_every_game_speed` (test_combat) presses Throw and Spell for real
at 100 and 70% across an empty hall:

| | 100% | 70% |
| --- | --- | --- |
| Rune Dagger | 154 px | 157 px |
| Torrent | 355 px | 357 px |
| Stormcall | 260 px | 262 px |
| Kindle | 116 px | 121 px |

The dagger comes home in 25 frames on screen at full speed and 35 at 70%, never sooner. Bible 5.3
gains "Thrown and cast at every game speed (pass 480)". No off-hand code changed.

Mutation check: with the dagger's reach counted in real time (`step / Engine.time_scale`), the test
fails at 70% (108 px against 154).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Score unchanged. The dagger and the spells are proved with the buttons at a slower speed. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 481: World.
