# Pass 49: The Leaf Mantis

Combat (86) was the lowest category in play, and the Branches had no enemy of its own: hornets stood in. This pass
adds the zone's first, the **Leaf Mantis** (bible 7, Conflate), and two more rooms on the elves' road toward the town.

## What changed

- **Leaf Mantis** (`scripts/enemies/leaf_mantis.gd`, legend `m`), code-drawn at 2x like the Lantern Ghost.
  - Hides folded on a bough as three overlapping leaves that sway with the rest. It has no contact damage while it
    hides (a hint of a yellow eye gives it away to the sharp-sighted).
  - Within about seven tiles and level with you (110 px across, 48 up or down), it rears and spreads its scythes for
    0.5 s, flashing (the telegraph, above `Enemy.MIN_TELEGRAPH`).
  - Then it lunges along the bough at 260 px/s for 0.25 s. The scythes cut once per lunge for 16, and the slash is
    parryable. It stops dead at a wall or the bough's end, so it never throws itself off.
  - A lunge leaves it overreached for 0.8 s, arms slack, taking half again the damage.
  - Then it stalks you at a walk and unfolds again, or folds back into a leaf after 2 s without seeing you.
  - Strike one while it hides and it springs open into the unfold.
  - 30 HP, 9 XP, 4 to 8 gold.
  - The drawing is laid out in small units and drawn 1.6x on the half-pixel grid (`_px` snaps each rect's edges, so
    neighbours still tile).
- **Rooms** (both in `MATTOCK_ROOMS`):
  - Leaf Landing gains an east door (door 2) and a sign: "Some of the leaves are not leaves."
  - **Thicket Road** (41,-8, 60x23): a hedge of giant leaves that a pod vaults (or the glove climbs) with a mantis
    on top; a high bough with a mantis and a chest; a thorny dip with a plank to step on; a mantis on the road
    beyond; a pod up to a Mantra Shard.
  - **Canopy Bridge** (43,-8, 40x23): a plank bridge over a thorn gully with a mantis on it, a pod on the planks up to
    a chest, and the barred town gate of Conflate (next pass).
  - Sunlit Bough's hornets on the bark wall and the plank are now mantises.
- Bible 7 has the mantis's row. `levels/README.md` has the `m` legend row.

## Tests

- `test_enemies.gd`:
  - `test_leaf_mantis_hides_unfolds_lunges_and_is_soft_when_overreached`: harmless while hidden and far off; unfolds
    for at least the minimum telegraph; the lunge lands once; overreached it takes 15 from a 10 hit.
  - `test_leaf_mantis_springs_open_when_struck_and_can_be_parried`: struck while folded it unfolds; a parry at the
    end of its unfold takes no damage and staggers it.
- `test_reachability.gd`: Thicket Road and Canopy Bridge; every pickup reachable, no soft-locks.
- `test_soak.gd`: the Branches soak covers both new rooms.

## Screenshots

`/mnt/project-files/pass-49/`: `thicket_road.png` (mantises hidden on the hedge and the bough), `mantis_unfold.png`,
`mantis_lunge.png`, `mantis_recover.png` and `canopy_bridge.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 87 | An ambusher that rewards reading the scenery, a parry window and a punish window. |
| World and level design | 15 | 91 | Two rooms on the road to Conflate. |
| Art cohesion | 15 | 84 | Unchanged (on hold). |
| Bosses | 10 | 87 | Unchanged. |
| Systems | 10 | 87 | Unchanged. |
| Audio | 5 | 86 | Unchanged. |
| Stability and performance | 5 | 85 | Unchanged. |
| Faithfulness | 5 | 86 | Unchanged. |

Weighted score: 87.55 (up from 87.40).

## Lowest categories and next pass

Leaving Art aside (on hold), the lowest is Faithfulness (86) with Audio (86). Next: **Conflate**, the elves' town
behind the Canopy Bridge gate (the original's town: a shop, a Guru, a house that heals, elves who talk about the
Bloom), with its music.
