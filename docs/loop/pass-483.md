# Pass 483: The screens in real time

## Category

Systems.

## Audit

Leads: menu, map, dialog and HUD timers under a slower Game speed and a boss's slow motion.

- Pause leaves `Engine.time_scale` alone, so a screen opened over a paused game still gets a `delta`
  scaled by the Game speed (and by slow motion, or 0 in hitstop). Every screen that runs while paused
  (`PROCESS_MODE_ALWAYS`) took that `delta` as it came.
- The dialog box types at 60 letters a second and waits 0.15 s before taking a press; the menus wait
  0.12 s; the ending turns a card every 4 s and climbs its credits at a set speed; the flask shelf, the
  map's blink and the title's spores move with time.
- Passes 476, 477 and 482 moved the music, door fades and HUD banners to real time. The screens had been
  missed.

## Bug found

At 70% Game speed a line typed out in 86 frames instead of 60, a menu's input grace ran 43% long, the
ending's cards turned every 5.7 s, and its credits climbed at 70%. In the slow motion after a guardian's
death blow (30%) it was worse: the Everbloom's heart, whose win starts the ending, would have opened the
epilogue in slow motion.

## Fix

`DialogBox`, `ListMenu`, `MapScreen`, `SlotPicker`, `TitleScreen` and `EndingScreen` take each frame in
real time with `Feel.unscaled(delta)`. `test_the_screens_run_in_real_time_at_every_game_speed`
(test_systems) types a line, waits out a menu's grace and turns the ending's first card at 100%, at 70%
and in a 30% slow motion, each within its real time. Bible 14 (Accessibility) gains "Game speed slows
the game, not its screens (pass 483)".

Mutation check: with the six screens back on `delta`, the test fails 6 checks (all three, at 70% and in
slow motion).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Score unchanged. Every screen reads the same at every Game speed. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 484: Audio.
