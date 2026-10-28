# Pass 203: every find in the reachability proof

World's last pass (195) was the oldest apart from Art, so pass 203 takes World. I audited world and level design (bible 3 and 4, the layout rules in `levels/README.md`) against passes 196 to 202. The only world changes since pass 195 are pass 201's: the Pendant in the Matriarch's Mire, and the Magical Rod on a plank in Conflate, up a new ladder.

| Check | Finding | Verdict |
| --- | --- | --- |
| Conflate's new ladder (201) | It runs from the floor to the top plank row on the town's east side, clear of the doors and the people. Its top cell is a plank, as every ladder's is, and the checker climbs it. | fine |
| The Pendant (201) | It lies on the floor of the Matriarch's arena, in the corner away from the door. As in the original, it is easy to miss and costs nothing to reach. | fine |
| Save spacing, foe density | No room or foe has changed since pass 195. `test_no_room_is_far_from_a_rest` passes. | fine |
| **The reachability proof's pickups** | `levels/README.md` says every pickup must be reachable. The sweeps (`_pickups` in `test_reachability.gd`) read only the grid's pickup cells. Four finds are laid by `prop:` lines instead: the Joker Key, the Battle Helmet, the Pendant and the Magical Rod. None was in any sweep, and pass 201 had to add a test of its own for its two. Moving the Battle Helmet into solid rock would have passed. | **fixed: the sweeps read the finds too** |

## As built

- `Reach` keeps each room's finds (`rooms[id].finds`: kind, x, y, for every `prop:` in `Room.FOUND_PROPS`).
- `_pickups` in `test_reachability.gd` adds them, so every sweep checks them along with the grid's pickups:
  - the Mist's relics in the Mattock-set sweep;
  - the Joker Key and the Battle Helmet in the Fire-and-Thunder sweep past the conduit gate.
- Checked: with the helmet's prop moved to 0,0 (rock), `test_fire_and_thunder_open_the_daybreak_gates` fails, naming it.
- `test_the_pendant_and_the_rod_can_be_reached` (pass 201) stays, since it proves the relics come early (with the Mist's set); its comment now says the sweeps cover them too.
- Bible 14, the reachability checker, and `levels/README.md` now say prop finds are pickups.

Full suite: 3947 of 3947 checks passed, with no script errors (the sweeps check more inside the same checks, so the count is unchanged).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the reachability proof now covers every find, not just the grid's. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 204 takes Bosses (last pass 196, now the oldest).
