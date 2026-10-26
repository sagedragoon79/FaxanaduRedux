# Pass 123: the Spire Sentinel

Faithfulness (96.75) was the lowest category apart from Art. Here it means faithfulness to the original's world as the bible plans it. Bible 7 gives each zone four or five foe families, under the original's names where they exist.

I audited the other ways the game could be unfaithful:
- **Items:** the bible's list is complete. The Pendant and Magical Rod are left out on purpose.
- **NPC lines and places:** every zone and town is built.
- **Bosses:** all are built.

The one open item was the roster. Daybreak, the elves' shrine-islands, still listed a "Spire Sentinel" with nothing built behind it, and it was the last planned foe. Its other foes were a harpy in the air and a beetle on the floor, and nothing made the Spires' long climbs feel guarded.

## As built

**Spire Sentinel** (`SpireSentinel`, legend `]`):
- **Look:** a knight of pale shrine stone that the elves set to guard their stairs. It is helmed and crested, holds a halberd, and has the Sky Key's gold lightning cut into its breastplate. It is drawn in code at 2x.
- **Stone while watched:** while you face it, it never moves, and every blow clinks off it (the guard spark and sound).
- **Behind your back:** turn away within about 13 tiles (and roughly level) and its eyes light. It grinds after you along the floor at 64 px/s (`sentinel_grind`), kicking up grit. The moment you turn round, it is stone again. It stops at walls and edges.
- **So the danger is climbing away from it,** not facing it. That is the Spires' idea: these are guarded stairs.
- **The slam:**
  - In reach (40 px), it raises the halberd overhead while the glyph blazes, for 0.6 s (pose, white pulse, a rising hum, `sentinel_raise`).
  - Then it slams the halberd down in front of it for 16 (`sentinel_slam`, screen shake). The slam can be parried.
- **Cracked open:**
  - A parry staggers it. A slam that lands or misses buries the blade in the floor for 1.2 s.
  - Either way, bright seams crack across the stone and every blow lands in full.
  - Then it is stone again for 1 s before it can strike.
- **Stats:** 40 HP, contact 8, 10 to 16 gold, 20 XP. It can't be launched.
- **Placed:**
  - the Spire Foot, between the Thunder scroll and the conduit, so it follows you while you aim the bolt;
  - the bottom of the Spire Stair, so it follows you up the first planks.
- **Sounds:** `sentinel_grind`, `sentinel_raise` and `sentinel_slam` were rendered with `sfxgen.py`, at -18.7, -18.2 and -14.0 dB RMS. `levels.py --check` passes, and I checked out the unrelated sound effects that `sfxgen.py` rewrote.

## Screenshots

In `/mnt/project-files/pass-123/`:
- `spire_foot_sentinel.png`: the Sentinel as stone at the Spire Foot, beside the Thunder scroll.
- `spire_stair_sentinel.png`: the Sentinel at the foot of the Spire Stair under the climb, with a Storm Harpy and a Thunder Beetle above.

## Tests

In `test_enemies.gd`:
- `test_spire_sentinel_moves_only_behind_your_back`:
  - watched, it stays put;
  - a blow clinks off;
  - with your back turned it grinds after you, and you hear it;
  - it stops the moment you turn round and stays put.
- `test_spire_sentinel_slams_and_cracks_open`:
  - the raise lasts at least `MIN_TELEGRAPH`;
  - the slam does 16;
  - spent, a blow lands in full, and then it is stone again;
  - a parried slam does no harm, staggers it and cracks it open.
- `test_the_newer_foes_have_voices_of_their_own` covers its three sounds.
- The Daybreak soak and reachability tests pass with both rooms.

## Bible

- Section 7, the Daybreak row: the Spire Sentinel as built. The "Not yet built" row now has no planned foes left.
- 13.3, Audio, foe voices: its three sounds.
- `levels/README.md`: legend `]`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97 | Unchanged. |
| Combat and enemies | 15 | 97 | Unchanged. The Sentinel adds a foe that asks you to watch it. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 97 | Unchanged. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 97 | The roster the bible planned is complete: every zone has its full set of families. |

Full suite: 2413 checks, all passing.

Weighted score: 95.3125 (up from 95.3). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Combat, World, Systems, Audio, Stability and Faithfulness are now tied at 97. Movement weighs the most, so pass 124 takes Movement.
