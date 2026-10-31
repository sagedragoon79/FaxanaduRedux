# Pass 309: poison ticks show their number

Category: Systems (last pass 301).

## Audit

I checked the systems (bible 9 to 12 and 14: save, shops, skills, keys, the pause menu, options) against what passes 302 to 308 touched.
- **Drops and saves (passes 307, 308).** No drop is saved: `GameState` keeps no drop, and a drop is a child of its room, freed with it. Leaving and coming back, or loading, brings none back. The purse is the one thing on the floor that is saved, and pass 300 writes its moved spot into the save. Taking a War Glove or an Ointment from beside a pit goes through the same `Drop._collect` as anywhere: the Glove starts its timer and the Ointment goes into the pouch, which the pause menu shows.
- **Poison text (pass 306).** No line in the game names a poison amount. The toasts say "Poison! It will pass, or bread will settle it." and "The poison fades.", and Forepaw's physician only speaks of poison. The bible's numbers were brought up to date in pass 306.
- **The purse reloaded mid-fight (passes 293, 300).** The purse's moved spot is written into `GameState.data.purse` as the floor tears, and a load rebuilds the room untorn with the purse at that spot, on whole floor beside where the pit was. `test_a_purse_on_torn_leaf_moves_beside_the_gap` checks the saved spot.
- **Options.** Shake, flashes, rumble, speed and the volumes don't touch drops or poison. **But damage numbers did miss one loss of health.** With the option on, every blow, cut and hurt shows a number, but a poison tick changed the hero's health silently. Since pass 306 a tick takes 2 to 4 depending on the zone, so a player who turned numbers on to read the game couldn't read the poison.

## Fix

- `Player._tick_poison`: with damage numbers on, each tick spawns a number for what it took (`DamageNumber` kind `poison`), in the poisoned masks' green. A tick that takes nothing shows none.
- Test: `test_damage_numbers_show_each_poison_tick` (`test_systems.gd`). Off, a tick shows nothing. On, a Zenis tick shows a green 4. A tick at the last point or under an Ointment shows nothing. With the spawn taken out, it fails.
- Bible 14: a sentence in the damage numbers paragraph.

Screenshot: [poison-tick.png](/mnt/project-files/pass-309/poison-tick.png), the Heart Gate poisoned with numbers on. A green 4 rises over the hero, the same green as the masks.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: damage numbers now cover every loss of health. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 310 takes Audio (last pass 302).
