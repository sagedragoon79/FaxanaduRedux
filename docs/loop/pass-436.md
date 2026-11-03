# Pass 436: a tablet is no shield

## Category

Bosses (last audited in pass 428).

## Audit

Pass 435 kept a frozen hero from harm so that a foe could not strike someone reading a sign. Looking
at the guardian fights, thirteen arenas hold tablets. Reading one is a single Up press, and the box
freezes the hero, so a tablet read as a blade came down turned any blow aside, a guardian's included.
That was a dodge with no cost and no timing, made by the last pass.

## Bug found

With pass 435's fix, a Rot Dwarf's blow read under (Up five steps before the blade lands) never
landed: the dwarf swung through the frozen reader, and closing the box left the hero whole.

## Fix

The dialog box now pauses the world while it is open, as a menu does (13.3, pass 430), and lets it go
as it closes, but only if it was the one that paused it. A foe or a guardian holds still while you
read, and a blow you read under still lands once the box is away. Pass 435's frozen-hero guard stays
for a door's scroll, a fade and a respawn, which the player cannot time against a blow.
`test_a_sign_is_read_safely_beside_a_foe` (tests/test_rooms.gd) is rewritten: Up reads the tablet for
real five steps before the dwarf's blade lands, the dwarf holds still for five seconds and nothing
lands, and after Attack puts the box away the same blow lands. Bible 14's line now covers both passes.

Mutation check: leaving the world running while the box is open fails the new test (the dwarf's
windup runs on).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Score unchanged. A tablet in an arena is no longer a free dodge for a guardian's blow. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 437: Systems.
