# Pass 11: the Grub Lump and the Burrows

Date: 2026-10-23. Scope: World (62) and Combat (73). The Trunk Hollows had 17 of 28 rooms and
four of their five enemy families.

## What was built

- **Grub Lump** (`scripts/enemies/grub_lump.gd`, sheet from `castgen.py`): a bark-plated grub
  that crawls tile to tile over floors, walls and ceilings, climbing inside corners and wrapping
  around outside ones, its body turning smoothly at each. Crossing a ceiling with you below, it
  stops, rears and shivers (0.45 s telegraph), then drops on you. It lands stunned for 0.6 s,
  open to a counter, and crawls on along the floor. Room legend `U`: it clings to the floor
  first, else the ceiling, else a wall.
- **Burrow Drop** (map 8,2): a shaft down through a new floor door in Deep Roots. Grubs cling to
  the roof over the landing; a plank stair climbs back up. A chest sits under a root mass.
- **Grub Burrows** (map 9-10,2): low grub tunnels either side of a tall chamber, with a plank
  climb to the zone's third Mantra Shard, a sap dip and a Monodron.
- **Lantern Grotto** (map 11,2): a fungus-lit cave with a sap pool and a chest, and a sheer
  chimney (Climbing Glove) up into a new floor door in the Grub Warren. Before the glove the
  branch is a dead end you walk back out of; after it, a loop from Deep Roots to the Warren.

## Automated verification

New: the Grub Lump climbs the wall and crosses the ceiling without leaving open space; from a
ceiling it telegraphs for at least `MIN_TELEGRAPH`, drops, hurts the player below, lands on the
floor and crawls on; its sheet has every state. The new rooms pass reachability (with and
without the glove and amber), soft-lock and boot checks. Screenshots reviewed: all three rooms
with grubs on roofs, walls and the chimney; the grub sheet at 6x.

## Review against the bible

- 3: Trunk Hollows 20 of 28 rooms, three landmarks.
- 7: all five Trunk families are in; every attack telegraphs.
- 3.2: the new loop gives the glove a second use in the zone (the grotto chimney).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 75 | Five families; the grub makes ceilings a threat. |
| World and level design | 15 | 65 | 20 rooms, a third loop, the third Mantra Shard. 8 rooms short. |
| Art cohesion | 15 | 65 | Unchanged; the grub reads at game scale. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 62 | Unchanged. |
| Stability and performance | 5 | 63 | A full Actions artifact quota no longer fails CI. |
| Faithfulness | 5 | 54 | Unchanged. |

Weighted score: 71 (up from 70).

## Lowest categories and next pass

1. **Faithfulness (54):** Faxanadu touches (the King's opening, the original's item names,
   the meteor in the sky).
2. **World (65):** the last 8 Trunk rooms, then the Tower of Trunk.
3. **Art (65):** prop and tile polish, alongside the Autosprite character work in its own thread.
