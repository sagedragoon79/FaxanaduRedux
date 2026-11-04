# Pass 454: the Guru's pages, heard through the buttons

## Category

Audio (last audited in pass 446).

## Audit

First, the music after a death in a fight. Pass 452's test already holds that a fight lost beside its own
shrine falls back to the zone's music at its written pitch. A rise in another room starts the zone's
track afresh (`Music.play` sets the intensity back to 0 and the pitch to 1). A phase break's duck runs
1.4 s, and that is over before the 1.2 s respawn's crossfade can meet it. Nothing was wrong there.

The Guru's own pages had never been listened to with the buttons. Pass 398 heard the list menus,
pass 406 the shrine and the map, and passes 451 and 453 walked the Mantra Path and the skill tree with
the buttons, but without listening to them.

## Bug found

None.

## Fix

`test_the_gurus_pages_are_heard_through_the_buttons` (tests/test_economy.gd) presses for real at a
Guru. Down blips. Jump on a skill learns it with the `rank` chime, and Jump on it again plays
`menu_refuse`. Dash backs out to play quietly. Jump on Unlearn skills is heard as `heal`, and again with
nothing learned as `menu_refuse`. Jump on a stop of the Mantra Path plays the `save` chime once, and is
never heard as a `jump`. Bible 13.3 gains "The Guru's pages, heard through the buttons (pass 454)".

Mutation check: taking the chime out of the Mantra Path fails the test ("heard by the save chime once
... ([])").

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. The Guru's pages are heard through the buttons. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 455: Stability.
