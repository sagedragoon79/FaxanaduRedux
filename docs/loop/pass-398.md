# Pass 398: every press in a menu is heard

## Category

Audio (last pass 390).

## Audit

- The mix is clean: `tools/audio/levels.py --check` passes (166 sound effects at a median of -18.5 dB, 34 music files at -14.7 dB, 14 ambience files at -21.4 dB).
- The "every sound heard" gate from pass 390 still holds on an unfiltered run.
- The three shrines added in pass 396 use the shared shrine code. Their save chime is heard on every unfiltered run (the pass 390 gate), though no single test listens for it; that is left for a later Audio pass.
- The gap: pass 397 drove the menus and the flask shelf with the real controller, but checked only what they did, not what they sounded like. Every menu sound (`blip`, `menu_refuse`, `flask_pour`, `flask_uncork`) was held only by calling the menu's own functions. A press that moved the cursor in silence, or a refusal that made no sound, would have passed.

## Fix

`test_every_press_in_a_menu_is_heard` (test_systems.gd) taps each button through the real input path and hears what plays:

- In a list menu, Up and Down blip, Left and Right blip on a row with a value, and Jump or Attack on a row you can't choose plays `menu_refuse`. Left or Right on that row is quiet, and so is backing out with Dash.
- On the flask shelf, Left and Right blip, and Block on a full flask asks with a blip. Dash keeps the flask quietly, then Block and Jump pour it out with `flask_pour`. Block on an empty flask is quiet, and Jump on an empty one plays `flask_uncork`.

Bible 13.3 gains "Every press in a menu is heard (pass 398)".

Mutation check: removing the blip from `ListMenu.move` fails the test twice (Down and Up are heard as silence).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score. Every press in a menu is heard through the real buttons, and a test holds it. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 399: Stability.
