# Pass 471: Key doors with marks of their own

## Category

Story and world.

## Audit

The memory's open item since the rename: the key doors still wore card suits. The pass 461 rename
gave the doors and keys their metal names, but every door still bore a playing-card suit: a spade, a
heart, a club, a diamond, and on the Glass door a "jester's star". These are the card keys of the game
Yldenfall began as, which bible 1 and 2 retire. No player text says "card", so
`test_no_retired_name_is_left` could not see it. The suits showed only in the art.

## Bug found

The key doors' glyphs were the source game's card suits.

## Fix

Each door now bears a mark of this world, and each mark has a shape of its own. Bible 14 tells the
gates apart by shape, for colorblind players.

| Door | Mark |
| --- | --- |
| Copper (oak) | a gold acorn |
| Silver (red lacquer) | a pale Ylden leaf |
| Gold (blackened iron) | the Reeve's crown |
| Thorn (elf-silver) | a blue thorn |
| Glass (violet) | a stillglass shard, with its winking glint |

`KeyDoor.CARDS` is now `KeyDoor.DOORS`, and its `suit` field is now `mark`. The glyph is drawn by the
static `KeyDoor.draw_mark`. The comments on the map are reworded the same way.

Bible 3's "Key doors" line and bible 14's Accessibility line now name the marks.
`test_the_key_doors_wear_marks_of_their_own` checks each door's mark, that the five are distinct, and
that the door script names no suit. It also builds each door and checks the bible. Screenshot (each
door at 6x): `/mnt/project-files/pass-471/doors.png`.

Mutation check: giving the Gold door a club again fails the test (2 checks).

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
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 97 | Score unchanged. The last of the source game's card art is gone from the doors. |

Weighted: 96.7625.

## Next

Pass 472: Combat.
