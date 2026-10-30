# Pass 298: a fall is a kill, not a blow

Category: Combat and enemies (last pass 290).

## Audit

I checked combat (bible 5.3, 5.5 and 7) against what passes 291 to 297 touched.
- **A foe knocked out of its room (pass 291).** Its death goes through `Enemy.die` like a blow's. It pays gold, a drop and experience, plays `enemy_die`, and refills Wanderer's Grace, and all of that is right: the blow that sent it there was yours. Bloodletting heals on a hit, not a kill, so a fall doesn't touch it. The game keeps no combo counter for kills. **But the kill also froze the game for 0.08 s and shook the screen.** That came a moment after the blow, while the foe was out of sight below the room, so the game hitched for nothing you could see.
- **The set-back (pass 296)** drops buffered presses only. A Riposte comes from a parry, and you can't parry spikes, so no parry window is open when they set you back.
- **Dying in a torn pit (passes 292, 293).** An Elixir or Second Wind saves you where you are, in the pit. The thorns below then set you back beside it, for one mask. A death there leaves the purse on the safe ground (pass 293).
- **The mana orb (5.3).** +12 MP is 80% of a Deluge (15) and 60% of Fire (20). At 2 MP a second, that is 6 s of regeneration. It is still a top-up, not a free cast.

## Fix

- `Enemy.fell` is set by `_fall_out_of_room`. `die` skips the kill's hitstop and shake when it is set, and keeps everything else. A respawn clears it.
- Test: `test_a_foe_that_falls_out_pays_without_a_kills_freeze` (`test_combat.gd`). A Monodron drops through a gap in the floor. It must die, pay its gold, and leave no hitstop or trauma. With the check taken out it fails (hitstop 0.08, trauma 0.25).
- Bible 7: a sentence after pass 291's paragraph.

No screenshot: nothing on screen changes except a hitch that no longer happens.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: a fall kill no longer hitches the game. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 299 takes World (last pass 291).
