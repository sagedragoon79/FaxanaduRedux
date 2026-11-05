# Pass 469: Ended and begun again, by the buttons

## Category

Stability.

## Audit

Followed the lead of state that the ending, the title or a load does not reset (as in passes 465 and
468). A probe ran the whole game from the Everbloom's death to the title and into a new journey in one
run. It checked the pause, the HUD and its hero, the old world and hero (freed), the World count (one),
`Engine.time_scale`, the menu's panel, the music and its bed, the map's and debug HUD's world, the
`cleared` flag, the fader, and a real Right walk. All clean, and the runner found no leaks. The ending
itself had only been driven with `skip`, `tick` and `advance`, never with the buttons.

## Bug found

None. A proof.

## Fix

`test_the_game_is_ended_and_begun_again_with_the_buttons` runs the whole game by the buttons:
- Jump and Attack turn the epilogue's cards.
- Pause skips to the thanks card and opens no pause menu.
- Jump inside the thanks card's grace does nothing; after it, Jump returns to the title.
- That Jump opens no flasks, and the title plays its theme over no bed.
- Jump on Journeys and Jump on an empty flask (test flasks 97 to 99) begin a fresh journey at the West
  Gate, with the HUD on the new hero, the ending gone, and Hearthroot's theme and bed.
- The hero walks on a real Right.

Bible 14 gains "Ended and begun again, by the buttons (pass 469)".

Mutation checks: dropping `_check_pause`'s ending guard fails 1 check (Pause opens the pause menu over
the ending); dropping the thanks card's grace fails 4.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Score unchanged. A full end-and-restart run is proved with the buttons. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 470: Movement.
