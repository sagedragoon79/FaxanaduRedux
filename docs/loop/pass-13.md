# Pass 13: root-gates and the western roots

Date: 2026-10-23. Scope: World (65). The Trunk Hollows had 20 of 28 rooms and two save shrines,
and the bible's Trunk gimmick, root-gates, was not built.

## What was built

- **Root-gates** (`scripts/world/root_gate.gd`, legend `R`) and **Root Hearts**
  (`scripts/world/root_heart.gd`, legend `N`): a woven pillar of living roots blocks a passage
  until you strike the room's heart, a pulsing amber bulb. Then every gate in the room draws back
  into the ceiling and stays open (`roots:<room>` flag). Both are drawn at 2x render density.
  Bible 3.3 now describes them.
- **Reach checker:** a root-gate is solid until its room's heart is touchable; `reachable()`
  repeats the flood until no more hearts come in reach.
- **Rootbound Hall** (map 6-7,1): down a new floor door in the Sap Tunnel. A root-gate seals the
  west end; the heart sits on a high shelf on the east side, past a Rot Dwarf, a Hornet, a
  Monodron and a ceiling Grub. A floor door at the east end drops to the Rootway.
- **Root Shrine** (map 5,1): behind the gate, the zone's third Meditation Shrine, with a Mana
  Dew on a plank climb.
- **Rootway** (map 7,2): a Sap Spitter, a sap dip and a ceiling Grub, joined to a new left door
  in the Burrow Drop. With it the western roots loop: Sap Tunnel, hall, Rootway, Burrow Drop,
  Deep Roots, Shrine Hollow and back.

## Automated verification

400 checks pass. New: the gate blocks the player, the blade strikes the heart, the room remembers, the gate draws
back and is still open when the room is built again; the checker keeps a heartless gate shut and
opens one whose heart is in reach. Root Hearts count as pickups, so the reachability test proves
every heart can be struck. The new rooms pass reachability, soft-lock (with and without the glove
and amber) and boot checks. Screenshots reviewed: the gate beside the sign, the heart on its
shelf, the shrine and the Rootway.

## Review against the bible

- 3: Trunk Hollows 23 of 28 rooms; the zone gimmicks (sap pools and root-gates) are both in.
- 3.1: three shrines in the zone (bible asks 2 to 3); every room is within 4 of a save.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 75 | Unchanged. |
| World and level design | 15 | 68 | 23 rooms, root-gates, a western loop, a third shrine. |
| Art cohesion | 15 | 65 | Unchanged; the gate and heart are the first 2x props. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 62 | Unchanged. |
| Stability and performance | 5 | 63 | Unchanged. |
| Faithfulness | 5 | 60 | Unchanged. |

Weighted score: 72 (72.1, up from 71.6).

## Lowest categories and next pass

1. **Faithfulness (60)** and **Audio (62)**: lightly weighted.
2. **Art (65):** tiles and decor to 2x density.
3. **World (68):** the last 5 Trunk rooms, then the Tower of Trunk.
