# Pass 243: the flask's true ceiling

World's last pass (235) was the oldest apart from Art, so pass 243 takes World.

| Check | Finding | Verdict |
| --- | --- | --- |
| Critical path, soft-locks, rest spacing | `test_reachability.gd` and `test_no_room_is_far_from_a_rest` pass. | holds |
| Gated finds | AMBER, MATTOCK, BOOT, STRIDE, WIND and FIRE secrets are each proven. The Boots ones were proven with real jumps in passes 219 and 235. | holds |
| Hidden rooms | Every zone of five rooms or more hides one (pass 131). | holds |
| **Find counts against bible 5.1 and 11** | I counted every find the rooms lay. Life Fruit (13), Mana Dew (9) and Meteor Shards (5) match. **Potion Shards: 18 against the planned 9** (Trunk 5, Tower 8), so the flask could reach 8 charges, not the 5 that 5.1 sets as the most. That is twice the healing the fights were balanced for. **Mantra Shards: 17 against 15**, which with the trials' six made 23, so two were spare forever. No test held the counts, so they drifted as rooms were built. | **fixed** |

## As built

- Nine Potion Shards became gold chests at the same cells: the Dwarf Larder, the Mossy Overhang and the Taproot Vault (200 g) in the Trunk, and the Cistern, Gear Shaft, Ore Bin, Rail Gallery (220 g), Sorting Floor and Winch Hall (220 g) in the Tower. Each chest is on a floor or plank. The two shards floating in midair (the Dwarf Hall and the Sap Tunnel) stay shards. A chest's id is its room and cell, the same as the shard's, so a save that took the shard finds the chest already open. Such a save keeps any charges it fused.
- Two Mantra Shards became chests: the Slag Heap and the Marsh Road (300 g). The rooms' 15 and the trials' 6 make 7 whole points.
- `test_the_rooms_hold_the_finds_the_bible_counts` (`test_economy.gd`, new). The rooms hold 13 L, 9 W, 9 F, 15 * and 5 (. The flask tops out at 5, and the Mantra Shards make whole mantras.
- Mutation check: with one shard put back, the test fails ("9 of 'F' (10)").
- Bible 5.1 (flask row), 9 (Mantra Shards) and the 11 table.
- Screenshots: `/mnt/project-files/pass-243/taproot_chest.png` and `winch_chest.png`. Each chest sits on its ledge.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged score: the finds now match the plan, and a test holds them. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 244 takes Bosses (last pass 236, now the oldest).
