# Pass 291: a foe knocked out of its room falls to its death

Category: World (last pass 283).

## Audit

I read bible 3 and 4 and the room rules in `levels/README.md` against what passes 284 to 290 touched.
- **Spike set-back (pass 288).** I looked for fleeting footing next to a spike in any room. The only matches are the Mist's drowned boardwalks (`b`), which are laid over spiked dips by design. They are tiles of the room, so they count as safe ground. No room puts a cracked block, raft or gate beside a spike.
- **The Myconid's sure bread (pass 289).** The Myconids stand on solid floor in the Mist and at Zenis's Heart Gate. The spoils soak (pass 287) already holds every foe's loaf to its room.
- **The drop odds (pass 290)** do not touch the world.
- **The gap is foes.** Pass 287 asked whether a pickup could leave a room; I asked the same of a foe. In every room I drove every walking foe with blows, first to one side and then the other. **Fifteen foes in fourteen rooms went out through a gap in the floor and fell on below the room for good:**
  - Monodrons and Rot Dwarves in the Trunk and the Tower;
  - a Marsh Hag in Fog Cut.

  A fallen foe never died, so its gold, drop and experience were lost. Its body went on falling until you left the room.

## Fix

- `Enemy._fall_out_of_room`: a foe that falls more than `FALL_MARGIN` (24 px) below its room's floor line dies as it goes. Guardians are left out.
  - It counts as a kill.
  - Its coins and drop come to rest at the gap's edge (`Drop.keep_in_room`).
  - One that respawns comes back as usual.
- Test: `test_a_foe_knocked_out_of_its_room_falls_to_its_death` (`test_rooms.gd`). In every room, every walking foe gets enough health to survive the blows and is driven both ways. It checks three things:
  - at least ten fall (15 do);
  - none is left alive below its room;
  - every coin rests on a floor inside the room.
- Mutation check: without the fall check, all 15 foes are left alive below their rooms.
- Bible 7: a paragraph after the rare drops.
- No screenshot: the change happens below the room's edge, out of sight. The test checks it.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: no foe can leave its room alive through a floor gap. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 292 takes Bosses (last pass 284).
