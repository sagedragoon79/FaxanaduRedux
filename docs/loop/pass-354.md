# Pass 354: every tell flashes the foe white (Combat)

Category: Combat (last pass 346).

## Audit

Bible 7 says every enemy telegraphs with "a pose, a flash and a sound", and 6.7's Flash line (pass 161) says the tell's pulses wash the foe's own silhouette white. The wind-up times are held by `test_every_wind_up_in_the_game_is_fair` (234), and the sounds by `test_every_attack_tell_and_strike_has_a_sound`. Nothing held the flash.

A read of every foe's `_draw` found that the 20 foes washed or drawn white with `telegraph_pulse()` in their tell, and five that were not:

| Foe | Tell | What pulsed instead |
| --- | --- | --- |
| Clockwork Hound | `wind` | its eyes |
| Shade Knight | `thrust_tell`, `cut_tell`, `riposte_tell` | the light at his blade's point |
| Crystal Dwarf | `windup` | his crystal fist |
| Meteor Slug | `swell` | the magma in its cracks |
| Spring Eel | `coil` | the lamp on its brow |

Each glow is a fine touch, but a player who has learned that a foe goes white before it strikes reads these five late, and three of them hit hardest in their zones.

## Fix

- The five now pulse white through their tells (the same `wash` and `telegraph_pulse` the others use) and keep their own glows.
- `Enemy.drawn_white()`: true when a foe last drew itself white, by the wash or by a sheet or overlay drawn white (the Grub Lump and the Lantern Ghost draw their own white overlays and now say so).
- Bible 7: "Every tell flashes the foe white (pass 354)".
- `test_every_foes_tell_flashes_it_white` (test_enemies.gd):
  - finds every tell state each foe sets (`set_state` or the Shade Knight's `_open`; 27 in all);
  - sets the foe into each, with its pulse on;
  - checks that it draws white.
  - Two exceptions are named in the test: the Minecart Rider's `charge` is its run (its tell is the rev), and the Meteor Seed is a shard whose flicker is its flash.

Mutation: with the Spring Eel's and the Shade Knight's washes back as they were, the test names all four of their tells.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score. Every foe's tell now reads the same way. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 355 takes World (last pass 347).
