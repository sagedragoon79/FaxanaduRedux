# Pass 489: The spell gates by the buttons

## Category

World.

## Audit

Leads: the gates the renamed spells open, with the real Spell button at 70% Game speed; lifts and moving
platforms through hitstop.

- The four spell gates (the Marsh Road's fire seal, the Dry Cistern's basin, the Spire Foot's conduit and
  the bell cellar's bramble) were each proved with a scripted `spell_pressed` at full speed, and the
  bramble's with a fireball placed by hand, never thrown by the hero.
- Lifts and platforms move on game time and stand still in hitstop like every other world object
  (pass 481's audit); the runner turns hitstop off, and pass 488 showed how a test must wait it out.

## Bug found

None. A proof.

## Fix

`test_the_spell_gates_open_by_the_buttons_at_the_slowest_game_speed` (test_world) readies each spell and
presses the real Spell button at 70%: Deluge douses the seal and fills the basin, Tempest Lance wakes the
conduit, and Emberfall, thrown from the floor, sets the bramble alight, each paying its MP. Bible 4.5
gains "The spell gates by the buttons, at the slowest speed (pass 489)".

Mutation check: with the Spell button dropped below full speed (`PlayerInput.poll`), the test fails
(9 checks).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Score unchanged. The spell gates are proved with the real button at 70%. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred to the art loop). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Story and world | 5 | 98 | Unchanged. |

Weighted: 96.8125.

## Next

Pass 490: Bosses.
