# Pass 16: the Trunk Hollows reach 28 rooms

Date: 2026-10-23. Scope: World (68). The bible gives the Trunk Hollows 28 rooms; 23 were built.

## What was built

Five rooms, each closing a loop or hiding something, so the zone rewards poking around
instead of only leading on:

- **Mossy Overhang** (5,-1, two screens): over the Hollow Mouth. A ceiling shaft from the
  entrance (new one-way platforms there climb to it) leads to Apolune's west wall, a second
  way into town. A Potion Shard on a high shelf, and a fake bark wall hiding a chest.
- **Hollow Knot** (4,1): behind a fake wall in the Root Shrine. A Life Fruit sealed in an
  alcove by a root-gate, whose Root Heart sits on a knob up a short platform climb, guarded by
  a Sap Spitter and a Hornet.
- **Sapwell Deeps** (12,2): east of the Lantern Grotto, across a long sap pool. A chain of
  platforms from the west bank climbs to a chest shelf. Sap Spitter, Rot Dwarf, Grub Lump.
- **Dwarf Larder** (13,2): casks of hardened sap, a Potion Shard on top, and a platform climb
  to a ceiling shaft up into the Sap Cistern. That makes a loop: Grotto, Deeps, Larder,
  Cistern, Grub Warren, Grotto.
- **Heartwood Rise** (14,0, two screens tall): joins the Cistern to the Taproot Vault, which
  was a dead end, with a platform climb. A sheer three-wide chimney beside it takes the
  Climbing Glove to a Mana Dew on a lip of bark.

Doors were added to the Hollow Mouth, Apolune, the Root Shrine, the Lantern Grotto, the Sap
Cistern and the Taproot Vault. The new rooms add 1 Life Fruit, 2 Potion Shards, 1 Mana Dew and 2 chests.

## Automated verification

Reachability passes: with the glove every pickup, chest and shrine is reachable; nothing
soft-locks; the boss is still behind the glove. The first layout failed it twice, and the
fixes were real ones. The Deeps' first platform could only be reached from inside the sap,
which is too deep to jump out of. The Mana Dew floated mid-chimney with no place to touch it.
Every door pairs up. The boot test caught one more: the Overhang's door 1 was the floor shaft, so
a player starting there fell straight back out. Its doors were renumbered so it starts at the Apolune
side. Full suite: 413 checks pass. Screenshots reviewed of all five rooms.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 75 | Unchanged. |
| World and level design | 15 | 71 | The Trunk Hollows are complete at 28 rooms with three new loops and two new secrets. The Tower of Trunk is not started. |
| Art cohesion | 15 | 71 | Unchanged. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 62 | Unchanged. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 73 (73.40, up from 72.95).

## Lowest categories and next pass

1. **Faithfulness (60)** and **Audio (62)**: lightly weighted. Faithfulness: original names, the
   Faxanadu item and NPC beats in Apolune.
2. **Bosses (68)** and **World (71)**: M4 starts the Tower of Trunk (Mattock, Zoradohna).
3. **Art (71):** enemy and NPC sheets to 2x (`castgen.py`).
