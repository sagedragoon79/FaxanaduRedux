# Pass 306: poison bites as hard as the room's foes

Category: Combat and enemies (last pass 298).

## Audit

I checked combat (bible 5.3, 5.5 and 7) against what passes 299 to 305 touched.
- **Poison against the zone threat (pass 305).** Poison took a fixed 2 health a tick, 16 at most. Crystal Dwarves in Dartmoor and every corrupted foe in Zenis drop it, and there every foe's blow is doubled (`ZONE_THREAT` 2.0) against a hero of up to 280 health. **16 health there is under 6% of the bar, a flask not worth stepping around**, while the bible calls it a hazard to step around. Poison is a foe's leaving, so it should bite as the room's foes do. The manual's Poison is "a fixed amount", but 5.5 already scales every foe's blow by zone, and pass 305's note covers how the remake's poison differs.
- **Foes at floor and ceiling doors (pass 299).** `test_every_door_up_or_down_lands_you_on_footing` rides all 54 floor and ceiling doors and fails on any hurt during the ride and the landing. None hurts, so no foe stands where it can hit you before you can act. Foes don't change rooms, so none can follow.
- **An Ointment over poison already ticking (pass 302).** `_tick_poison` skips a tick while an Ointment is on, and the poison's 8 s keeps running under the Ointment's 10 s. So an Ointment rubbed on mid-poison stops the rest of it, which fits the bible's "an Ointment keeps it off". No test held it, so the new test does.
- **Blade arcs against hitboxes (pass 298, #332).** The hitbox grows by the blade's `reach_bonus` and `arc_bonus`, and the slash effect drawn over the swing (`SlashFx`) scales by the same two numbers, so the arc you see is the arc that hits and knocks a foe into a gap. The blade drawn into the hero's own frames is Sean's PixelLab art, which I left alone.

## Fix

- `Player.poison` scales each tick by the room's threat when it takes, as `_threatened` scales a blow: 2 in the Tower, 3 in the Mist, the Branches and Daybreak, 4 in Dartmoor, the Sunken Spring and Zenis. It still never takes the last point.
- Test: `test_poison_bites_as_hard_as_the_rooms_foes` (`test_economy.gd`) poisons the hero in the Tower, the Mist and Zenis and counts each tick, checks the last point is spared, and checks an Ointment rubbed on mid-poison stops the rest. With the fixed tick put back, it fails in the Mist (3) and Zenis (4).
- Bible 7: a sentence after pass 305's note, and pass 305's "16 health at most" now says in the Tower. Bible 10.2's dropped Poison cure gives the new range.

No screenshot: nothing on screen changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: late poison is a hazard again. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 307 takes World (last pass 299).
