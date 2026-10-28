# Pass 191: the dagger in every soak, and gear in its own slot

Stability's last pass (182) was the oldest apart from Art, so pass 191 takes Stability. I audited stability and performance (bible 15) against the newest content (passes 182 to 190).

| Check | Finding | Verdict |
| --- | --- | --- |
| **The Rune Dagger in the soaks (pass 184)** | No soak threw it. The mashing hand pressed every other button, so every room's walls, doors, gates, planks and water, and every boss fight's new `take_throw`, had met the dagger only in its own tests. | **built** |
| **Gear in the wrong slot (passes 185, 186)** | `sanitize` kept whatever a save wore. A known item in the wrong slot loaded as worn, for example plate as a blade or a sword as a helmet. Refreshing the stats then read it as that slot and played it as nothing, and the Equipment page showed it under no header while it stayed "worn". | **fixed** |
| The cloak's verlet layer (PR #206) | It treats a jump of more than 16 px as a teleport and hangs afresh, so doors and respawns don't fling it. It is drawn in every soak. | fine |
| A dagger left in another room | It comes home, as tested in pass 184. | fine |
| Prop finds as treasures (pass 187) | Their ids round-trip in a save; the journey soak walks the rooms. | fine |
| The new gear sounds (pass 190) | All exist, and the mix check passes. | fine |

## As built

- `test_soak.gd` `_mash`:
  - The hand throws the Rune Dagger every 25 frames.
  - The timing comes from a counter, not the soak's random number generator, so each soak mashes the same buttons as before. On the first try, drawing it from the generator moved the Hydra soak off the path that reaches the flood.
  - Each zone soak checks it threw at least once a room (`Player.throws`, a new counter like `thrusts`) and prints the count.
  - The first full soak threw 778 daggers across all the rooms, and more in the boss fights. Every check held: no stray position or embedding, no node growth past its budget, and the frame budget kept.
- `GameState.sanitize`: a known item worn in a slot of another kind comes off, and the blade slot falls back to the Short Sword. An unknown id stays, as pass 138 keeps it, and plays as none.
- Bible 15: the stability notes ("The mashing hand throws the dagger") and the pass 138 save note ("A slot holds its own kind").

## Tests

- `test_soak.gd`: every zone soak checks its dagger throws. The boss soaks throw too.
- `test_systems.gd`, `test_a_save_with_gear_in_the_wrong_slots_plays_on` (new). It loads a save wearing plate as a blade, the helmet as armor, a dye as a shield and a sword as a helmet, with junk in its gear list. It checks that:
  - the wrong-slot items come off and the hand holds the Short Sword;
  - the kept gear is strings, once each;
  - the Cloak section lists only owned dyes;
  - every Equipment row can be chosen;
  - the shops' statuses and a dagger throw run;
  - no engine error is logged throughout.

Full suite: 3542 of 3542 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged: the newest tool is soaked everywhere, and a bad save can't wear gear in the wrong slot. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 192 takes Movement (last pass 183, now the oldest).
