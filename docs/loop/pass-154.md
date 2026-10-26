# Pass 154: damage numbers

Combat (98.25, weight 15) was tied for lowest apart from Art. Of the tied categories it weighs the most along with World, and its last pass (147) was the older of the two. I audited combat against bible 5 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 5.3 and `combat_tuning.gd` | the table matches, Thrust's row included | fine |
| Thrust against guards | a thrust strikes along the facing like a cut, so a Shade Knight's shield, a Bark Knight's plates, a Thunder Beetle's shell and a Spire Sentinel turn it as they turn a cut; it breaks cracked stone with the Mattock and feeds MP like any blow | fine |
| Thrust's lunge (pass 153) | rides ramps, stops at the foe it strikes, steps off lips at a run | fine |
| Rare drops (pass 147) | the War Glove multiplies a thrust through `blade_mult()` | fine |
| **12 and 14: "damage numbers (optional toggle)"** | Never built. Since pass 140 a blow's worth depends on the blade, its temper, Keen Edge, the War Glove, a heavy finisher or thrust, and a foe's guard, plates or open moment. The only way to read any of it was a foe's health going down out of sight. | **built** |

## As built (bible 14)

- **The option:** an Options row, "Damage numbers", off by default, saved in `settings.cfg` with the rest (`Settings.damage_numbers`). A settings file from an older build loads it as off.
- **`DamageNumber`** (`scripts/fx/damage_number.gd`), drawn with `PixelFont`:
  - It shows the damage a blow actually dealt, after a foe's guard, bark or shell, over what it struck.
  - A cut is white. A heavy blow (the finisher, a thrust, a Riposte: anything that strikes at 1.8x) is gold and twice the size.
  - A hit on the player shows the HP it took, after armor, in red.
  - It rises 18 px with an ease-out and drifts a little to alternate sides, so a flurry doesn't stack into one number. It holds through the hit-stop and fades over the last 0.25 s of its 0.7 s.
  - A blow a shield turns deals nothing and shows nothing.
- **Where:** every foe and Enemy-based boss (`Enemy.take_hit`); the segment bosses, Rokusutahn and the lanterns, through `BossSegment` (measured off the boss's health, and skipped for a boss that is itself an Enemy, so nothing shows twice); the gym's training dummy; and the player.
- `game.gd`: `--damage-numbers` turns them on for a run, for screenshots.

## Screenshot

`/mnt/project-files/pass-154/damage_numbers.png`: the gym, a thrust into the training dummy; the gold 21 is a Hand Dagger thrust (heavy 14 x 1.5).

## Tests

`test_systems.gd`, `test_damage_numbers_show_what_each_blow_dealt` (new):
- off by default: a blow shows no number;
- the Options menu has the row, and turning it on works;
- a cut shows exactly what the foe lost, over the foe;
- a heavy blow's number is gold and larger;
- a blow the Rot Dwarf's shield turns shows none;
- a hit on the player shows the HP it took after armor;
- a number rises and is gone after 0.7 s;
- the choice is saved and loaded, and the suite goes back to the default.

Full suite: 2800 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.5 | Unchanged. |
| Combat and enemies | 15 | 98.5 | The worth of every blow, temper, skill and guard can be read in the fight, for players who want it. |
| World and level design | 15 | 98.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.25 | Unchanged. |
| Audio | 5 | 98.25 | Unchanged. |
| Stability and performance | 5 | 98.25 | Unchanged. |
| Faithfulness | 5 | 98.25 | Unchanged. |

Weighted score: 96.3375 (up from 96.3). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

World, Systems, Audio, Stability and Faithfulness are tied at 98.25, the lowest apart from Art. World weighs the most (15), so pass 155 takes World.
