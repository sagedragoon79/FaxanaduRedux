# Pass 58: the Spires and the Thunder spell

The way up from Daybreak town. This pass builds Thunder (bible 4.1, A6), the ability gate of the zone, with the dead
conduits it wakes and the gates they open. The first two rooms of the Spires use them.

## What changed

- **Thunder** (`scripts/combat/thunder_bolt.gd`):
  - Costs 18 MP. A fast crackling bolt (380 px/s) that strikes the first foe for 16.
  - Before it touches anything, it leaps in a jagged arc (`scripts/fx/lightning_arc.gd`) to any dead conduit within
    72 px that isn't behind it, and wakes it.
  - It lights the fog as it flies.
  - The Next Spell order is now Deluge, Thunder, Fire.
  - Taking a spell scroll as a pickup equips it if you have no spell yet, as buying one already did.
- **Conduits** (`scripts/world/conduit.gd`, legend `c`):
  - A copper coil on a stone plinth with a guttering blue spark. It isn't solid.
  - Once awake, it glows, arcs crawl up it, and it lights the fog (`spark_up.wav`). Each conduit remembers waking.
- **Conduit gates** (`scripts/world/conduit_gate.gd`, legend `k`):
  - Elf-silver shutters with a lightning glyph.
  - When the last conduit in the room wakes, every gate slides up for good (flag `conduits:<room>`).
  - `reach.gd` treats `k` as solid until the "thunder" ability.
- **The Thunder scroll** is a pickup (legend `h`, a violet-ribboned scroll with a flickering bolt).
- **Rooms**:
  - **Daybreak**: a passage through the bell tower, from the bell-loft gallery, to door 2 east.
  - **Spire Foot** (`daybreak/spire_foot`, 56,-11): the old lift-house. The scroll lies on the lectern, and one
    conduit stands before a gate three tiles tall.
  - **Spire Stair** (`daybreak/spire_stair`, 57,-12, 40x45):
    - Landings climb a hollow spire to a silver hatch three tiles wide.
    - The hatch opens only once both its conduits are awake, one on the floor and one on its own landing.
    - Above the hatch, a chest sits on the top landing below the roost. A beetle and a hornet are on the way up.
- **Bible**:
  - 3.2: the Spires as built.
  - 4.1: where Thunder is found.
  - 4.5: conduits and gates as built.
  - The README legend gains `c`, `k` and `h`.

## Tests

- `test_combat.gd`: `test_thunder_bolt_strikes_a_foe` (MP cost and a hit). The Next Spell test now accounts for
  Thunder.
- `test_world.gd`:
  - `test_thunder_wakes_the_conduit_and_opens_the_gate`:
    - The scroll grants and equips Thunder.
    - A bolt cast four tiles short of the conduit leaps to it.
    - The flag is set and the gate opens.
    - Re-entering the room finds both still open and awake.
  - `test_the_spire_hatch_needs_every_conduit`: one conduit isn't enough, and the second opens the hatch for good.
- `test_reachability.gd`:
  - The Spire Foot is added to `STRIDE_ROOMS`.
  - New `THUNDER_ROOMS` (the Spire Stair), excluded where Thunder isn't in the set.
  - `h` is counted as a pickup.
  - Suite time: on this machine the full suite reached about 30 minutes, past the local 25-minute cap. Most of it
    is the reachability floods with the Stride, about four minutes each. Pass 57's Fire test and this pass's Thunder
    test each ran two such floods.
    - The without-spell checks (the bell-ringer, the Thunder scroll, the bramble secret and the shut stair) now ride
      on the Stride test's existing flood.
    - `test_fire_and_thunder_open_the_daybreak_gates` runs one flood with both spells. It checks the cellar shard,
      the opened stair and its top chest, with no soft-locks.
    - This saves about three floods, around ten minutes.
- The room, door, soak and sound-file checks pick up the new rooms and the new sound on their own.

## Screenshots

`/mnt/project-files/pass-58/`:
- `spire_foot.png`: the lift-house, the scroll and the dead conduit.
- `thunder_arc.png`: a bolt leaping to the conduit.
- `gate_open.png`: the conduit awake and the gate up.
- `spire_stair.png`: the hatch and the landing conduit.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 88.5 | Unchanged (Thunder's combat use is small by design). |
| World and level design | 15 | 92.5 | A new ability gate that plays as a short puzzle, and the first Spires rooms. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 88.5 | Unchanged. |
| Systems | 10 | 89.25 | A sixth ability with persistence, gates and checker support. |
| Audio | 5 | 88.5 | One new effect. |
| Stability and performance | 5 | 86.75 | Unchanged (the reachability tests got leaner again). |
| Faithfulness | 5 | 88.75 | Thunder and the conduits, as bible 4.1 planned them. |

Weighted score: 88.76 (up from 88.69).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (86.75). Next is the Storm Harpy, Daybreak's flier (bible 7), placed up the
Spires. After it come the roost and Borabohra (bible 8.6), whose conduits on each island ground him. A stability pass
on the ObjectDB leaks is still queued.
