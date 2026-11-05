# Pass 468: No heartbeat under the ending

## Category

Audio.

## Audit

Followed the trigger's lead on music handed over at the title. Quit leaves the app, so the only way
back to the title is the ending. `test_the_game_plays_the_ending_then_returns_to_the_title` checked
the ending's track but never the ambience bed. `levels.py --check` is clean.

## Bug found

`_play_ending` changed the music and left the bed alone. The Evercrown's heartbeat (`amb_evercrown`,
the bed of the room where the Everbloom dies) kept beating under the ending and the credits. It was
still playing under the title theme that comes after them.

## Fix

`_play_ending` fades the bed out with the music (`Music.ambience("", 2.0)`). The ending test now checks
that the bed is gone during the ending, and that the title plays `title` over no bed. Bible 13.3 gains
"No bed under the ending or the title (pass 468)".

Mutation check: without the fade-out, the test fails ("amb_evercrown" under the ending).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. The ending and the title no longer carry the last zone's bed. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Unchanged. |

Weighted: 96.7625.

## Next

Pass 469: Stability.
