# Pass 259: Dartmoor drains

Category: World (last pass 251).

## Audit

I read bible 4.4's world-state table against the rooms. Every row but one changes the world you walk through: amber, boardwalks, winds, the lift, the fountain, the fog, the people.

The one exception was "King Grieve defeated: Dartmoor drains". Pass 73 built it as "a first step". The steward and a mason say the water is going down, and the lower tide line was deferred to the art pass. But no Dartmoor room had any standing water in it. The drowned capital was dry before the fight and dry after it, and the Flooded Hall's own sign ("The water still stands in the halls below") pointed at water that wasn't there. A player saw no change at all.

## Fix

- New header key `tide: ROW` and a `Tide` node (`scripts/world/tide.gd`). From that row down, every column open at it fills to the first tile below: a tile deep across the floor, and the spike pits filled.
  - The water is drawn translucent in front of what wades in it, so the spikes under it still show. Its surface is a pale line that breathes, with slow glints.
  - Steps in it sound wet (`Room.surface_at` gives `mud`). It is not deep enough to swim, it doesn't slow you, and it hides no hazard.
  - Once King Grieve is at rest (`boss:king_grieve`) it has drained. All that is left is a teal tide mark where the surface stood, behind the actors, and silt on the floor.
- The Flooded Hall and the Drowned Nave stand in it (`tide: 19`). The Upper Gate-Hall stays dry, because its sign already says the water stood there once.
- The Flooded Hall's sign has a line for after: "The water has gone down at last, and left its mark on every pillar."
- Test: `test_dartmoor_drains_when_king_grieve_is_at_rest` (`test_rooms.gd`). For both halls it checks four things:
  - the water stands in no rock;
  - it is a tile deep across most of the floor and fills the pit;
  - wading splashes;
  - after the king, the hall is dry and the floor sounds like stone.
  It also checks that no room outside Dartmoor has a tide.
- Mutation check: with the drain never coming, the test fails four checks.
- Screenshots, looked at: `/mnt/project-files/pass-259/flooded_hall.png` shows the hero wading and the spike pit filled, and `flooded_hall_drained.png` shows the dry hall with the tide mark.
- Bible 4.4 (the King Grieve row) and 8.7 are updated. The `levels/README.md` legend is updated.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the last spoken-only world change in 4.4 now shows. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 260 takes Bosses (last pass 252).
