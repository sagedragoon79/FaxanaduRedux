# Pass 338: every foe's numbers, written and held (Combat)

## Audit

Combat was last audited in pass 330, which put every spell in bible 5.3. This pass read bible 7 against `scripts/enemies`. The zone table tells each foe's fight in words, and every number it gives matches its script. But no test read any of it: only the Hour Glass test (pass 337) opened the bible from `test_enemies.gd`. The words also left gaps. Four Trunk Hollows foes (Monodron, Hornet, Rot Dwarf, Sap Spitter) had no wind-up at all, so 21 of 25 foes had one. Only 12 had a health, and the Iron Dwarf's slam (24), the Minecart's charge (22) and others had no damage. A tuning change to any foe would have left the bible behind without a failing test.

The drop table (bread, mana, poison, rare drops), threat scaling (5.5), the shield and dagger builds (5.2, 8) and the Hour Glass (4.1) are each held by tests from earlier passes.

## Fix

- Bible 7: the four Trunk foes' wind-ups go into the zone table: the Monodron crouches for 0.4 s, the Hornet buzzes in place for 0.45 s, the Rot Dwarf winds up his axe for 0.5 s, and the Sap Spitter swells for 0.55 s.
- Bible 7: a new table, "Every foe's numbers, as built (pass 338)", gives each of the 25 foes its health, touch, first wind-up and main blow. These are the scripts' numbers before zone threat.
- `test_every_foes_numbers_are_written_in_bible_7` (test_enemies.gd) checks several things:
  - every `Enemy` script in `scripts/enemies` has a row (the Meteor Seed is a death burst, not a foe);
  - each row matches its script: `max_hp`, the touch (a hidden foe's `CONTACT` or `TOUCH_DAMAGE`), the wind-up constant and the main blow's constant;
  - each wind-up is at least `Enemy.MIN_TELEGRAPH`;
  - the zone table's own words for each foe give the same wind-up, and any health or touch they state matches the script.
- The helper `_bracketed` finds a foe's words up to their closing bracket. It skips brackets in code, such as the Naga's legend `)`.

Mutation check: with the Iron Dwarf at 60 HP and the Hound's wind-up at 0.5 s, the test fails three times, naming both foes.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: every foe's health, touch, wind-up and blow is written in bible 7 and held to its script. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 339, World: audit passes 332 to 338 for world facts in the bible that no test holds or that the levels disagree with.
