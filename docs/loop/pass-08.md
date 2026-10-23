# Pass 08: the Amber Falls branch

Date: 2026-10-23. Scope: World and level design (52), the lowest category. The Trunk Hollows
had 11 of the 28 rooms the bible plans, no loops, one landmark-grade room besides Apolune, and
the spring's "new route to a secret" (bible 4.4) did not exist.

## What was built

- **Four rooms** (Trunk Hollows now 15):
  - **Amber Falls** (landmark, two screens tall): sap pours from a split in the heartwood into a
    hanging basin. The hall floor sits six tiles above the entrance, so the Glove Shrine's new
    back door leads straight into the first real wall-jump test. A Life Fruit glints in an
    alcove in a root mass beside the falls, out of reach until the spring is restored and the
    falls sets into an amber pillar you can climb.
  - **Grub Warren**: a long tunnel with two sap dips, a Rot Dwarf, Monodrons, Hornets and a
    chest, with a shaft up between two hanging roots.
  - **Gnawed Stair**: a chewed-out stair that joins the warren to the Gnawed Gate shrine above.
  - **Sap Cistern**: the dwarves' old sap tank (wade through it, or walk over it as amber) and
    a Mantra Shard on a high ledge.
- **Loops:** Glove Shrine → Amber Falls → Fungus Shaft (a new side passage halfway up, with a
  ledge to rest on), and the Gnawed Gate shrine drops through a one-way floor into the stair.
  Everything new needs the Climbing Glove, so the boss gate still holds.
- **Sap falls** (`SapPool.find_falls`): sap with open air beside it and more sap below draws as a
  pouring stream with streaks and a splash where it lands.

## Automated verification

327 checks pass. New: the amber-only secret is out of reach with the glove and reachable once
the sap hardens (`AMBER_SECRETS`); falls are told apart from walled pools. All rooms pass the
reachability, soft-lock and boot checks. Screenshots reviewed: Amber Falls low, high and after the
spring, Grub Warren (both screens), Gnawed Stair, Sap Cistern.

## Review against the bible

- 3 (zones): Trunk Hollows 15 of 28 rooms; Amber Falls is the zone's second landmark after Apolune
  (bible asks for 3).
- 4.4: the spring's new route to a secret now exists.
- 14: reachability proof covers the new rooms and the spring state.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 70 | Unchanged. |
| World and level design | 15 | 58 | 15 rooms, two loops, a landmark, a world-state secret. Still 13 rooms short. |
| Art cohesion | 15 | 65 | Unchanged; the falls reads well. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 63 | Unchanged. |
| Audio | 5 | 60 | Unchanged. |
| Stability and performance | 5 | 60 | Unchanged. |
| Faithfulness | 5 | 52 | Unchanged. |

Weighted score: 68 (up from 67).

## Lowest categories and next pass

1. **Faithfulness (52):** Faxanadu touches (Meat drops, the Mattock tease paid off later).
2. **World (58):** a third Trunk landmark, more rooms toward 28.
3. **Systems (63):** options menu (shake, flash, volume, rebinding).
