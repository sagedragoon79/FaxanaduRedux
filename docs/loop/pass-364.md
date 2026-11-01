# Pass 364: the boss bar, held (Bosses)

Category: Bosses (last pass 356).

## Audit

Passes 357 to 363 changed no guardian. The bosses' tables (numbers, openings, dying window, kill flash) and their tests still hold.

Bible 8's opening line promises "Health bars show phase markers". 8.8 promises that in Shadow Eura's third phase "the boss bar follows" the real one. No test had ever looked at the boss bar. `GameHud._draw_boss` drew it inline, with nothing a test could read:
- the name;
- the red fill;
- the pale trail of a blow, catching up at a bare `0.5` per second;
- a gold tick at each phase mark.

A guardian with a mark at 0 or 1, ticks drawn from the wrong end, or a false double that took the bar would each have passed every test. The bar is the player's only gauge of a fight, and the ticks tell them when the fight will change.

## Fix

- `GameHud.boss_bar()` returns the bar as drawn: the guardian, its name, the bar's rect, the fill, the trail and the ticks. `_draw_boss` draws from it, so the test reads exactly what is drawn. The trail's speed is now `BOSS_TRAIL_SPEED`, and the width `BOSS_BAR_WIDTH`. The look is unchanged.
- Bible 8: a note "The boss bar, held (pass 364)".
- `test_every_guardians_bar_shows_its_phase_marks`:
  - raises all 16 guardians in their own arenas. Each bar must name its guardian and fill to its health, with a tick inside the bar at each phase mark;
  - gives the Foreman a blow: the red drops at once, and the trail catches up at the written speed;
  - splits Shadow Eura below a fifth: the bar stays on the real one, and the double is not in the `boss` group.

Mutations: ticks drawn from the wrong end fail 10 guardians, and a trail that snaps to the fill fails 1.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score. The bar that every fight is read by is now held. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 365 takes Systems (last pass 357). The next Stability pass (367) should trace the frame bursts in `test_a_journey_after_the_end_stays_lean` seen in the full runs of passes 359 and 363.
