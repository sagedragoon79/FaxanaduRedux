# Pass 10: Taproot Vault and the Sap Spitter

Date: 2026-10-23. Scope: World (58) and Combat (70). The Trunk Hollows had two of the three
landmarks the bible asks for per zone, and only three of its five enemy families.

## What was built

- **Sap Spitter** (`scripts/enemies/sap_spitter.gd`, `sap_glob.gd`, sheet from `castgen.py`):
  a bark-rooted turret with an amber sac. When you come near, the sac swells and glows (0.55 s
  telegraph), then it lobs a glob in an arc solved to land where you stand. The glob hurts, and a
  miss leaves a puddle of sap (`Room.splash_sap`) that slows you for 4 s. Room legend `T`.
- **Hornet Gallery** (map 11,0): a thorn pit with stepping planks under three hornets and a
  Spitter, and a chest on a high ledge. It joins Amber Falls (a new door off the climb to the
  basin) to the Gnawed Stair, a second loop through the branch.
- **Taproot Vault** (map 13,0, the zone's third landmark): up a shaft from the Sap Cistern. The
  World Tree's taproot fills the room, bitten half through by Rokusutahn and weeping sap
  (`Taproot`, a drawn set piece). After the Spring of Trunk the bites close and amber light
  climbs the grooves. A Potion Shard waits on a ledge, guarded by a Spitter and a Monodron.
- **Test runner:** `tools/run_tests.sh` now caps the run (a script that fails to parse used to
  leave Godot idling until CI's 20-minute limit).

## Automated verification

370 checks pass. New: the Spitter's telegraph meets `MIN_TELEGRAPH`, its glob arcs at the player
and hurts, a missed glob leaves sap that dries; the Spitter's sheet marks its mouth; the taproot
is bitten until the spring heals it. The new rooms pass reachability, soft-lock (with and without
amber) and boot checks. Screenshots reviewed: the vault before and after the spring, the gallery
from both ends with a glob in flight, and the Spitter's sheet.

## Review against the bible

- 3: Trunk Hollows 17 of 28 rooms; three landmarks (Apolune, Amber Falls, Taproot Vault): met.
- 7: four of the five Trunk families (Grub Lump still to come); every attack telegraphs.
- 4.4: the spring now changes three things in the Trunk you can see (amber, Apolune, the root).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 73 | A ranged, area-denial enemy; four families. |
| World and level design | 15 | 62 | 17 rooms, three landmarks, two loops in the branch. 11 rooms short. |
| Art cohesion | 15 | 65 | Unchanged; the taproot holds up next to the tiles. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Unchanged. |
| Audio | 5 | 62 | Unchanged. |
| Stability and performance | 5 | 62 | The test run can no longer hang. |
| Faithfulness | 5 | 54 | Unchanged. |

Weighted score: 70 (up from 69).

## Lowest categories and next pass

1. **Faithfulness (54)** and **Stability (62)** are low but lightly weighted.
2. **World (62):** the remaining 11 Trunk rooms, and the Tower of Trunk after them.
3. **Art (65):** prop and tile polish, alongside the Autosprite character work in its own thread.
