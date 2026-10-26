# Pass 140: Meteor Shards for the smith

Combat (97.75, weight 15) was tied for lowest apart from Art with World, Systems, Audio, Stability and Faithfulness, and weighs the most of them with World. I audited combat against bible 4, 5 and 7 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 5.3 moves and numbers | Pinned line by line in pass 105; unchanged since | fine |
| 7 telegraphs, hurt, death, drops | Every foe through the Spire Sentinel telegraphs at least `Enemy.MIN_TELEGRAPH`; deaths dissolve (pass 126) | fine |
| 5.2 gear tiers | Every blade, armor and shield tier is built (Giant Blade pass 93, Magic Shield pass 91, Battle Helmet pass 118) | fine |
| **5.2 smith upgrades** | The bible says the Forepaw smith tempers each blade "for gold plus Meteor Shards". Only the gold was built, with a note that the shard cost "joins when shards are placed in the world". No shard had ever been placed, so a blade's best upgrade was a plain purchase, and the meteor that drives the story never touched your weapon. | **built** |

## As built

- **The pickup:** a Meteor Shard (legend `(`) is a splinter of the meteor: a black rock heel with three magenta crystal spurs and a cyan light beating in the crack between them, the colors of the Crystal Dwarves and of Zenis. It is an `ItemPickup` like the other shards. Its banner says how many you carry and that the Forepaw smith folds one into a second temper.
- **The cost:** Temper Blade II (1,600 g) now also takes one shard (`"shards": 1` on the shop entry, `Shop.shards`). Temper I stays gold alone, so the first upgrade comes as early as before. Without a shard the forge row reads "Needs shard", and the temper's line says how many you carry. Buying spends the shard with the gold.
- **The shards:** five, one per blade and one spare, so a shard spent on a blade you later put down isn't lost for good:
  - Tower, Crown Lookout: under the roof, a jump up from the potion-shard platform, near the smith who uses them.
  - The Mist, Scorched Hall: a jump above the west platform.
  - Branches, Sunlit Bough: in the hidden pocket beside the chest.
  - Daybreak, Broken Shrine: in the hidden pocket beside the chest.
  - Dartmoor, Meteor Rise: at the east end of a shelf on the king's road to the meteor.
- **State:** `GameState.data.meteor_shards`, a count. Sanitize clamps it at zero like every number. Old saves load it as 0, and a blade already tempered twice keeps its temper.
- **Completion:** shards are treasures (`World.TREASURE_CHARS`), so Treasure Sense finds them and the completion card counts them. A save that was at 100% before this pass now has five treasures still to find.

## Bible

- 5.2: the "joins when shards are placed" note is replaced by a **Meteor Shards (built pass 140)** block.
- 11 (secrets table): Meteor Shards go from "10, elite drops, hard rooms" to 5 in hard rooms and hidden pockets. Each blade takes only one shard, so ten would mostly be dead pickups. A foe drop would make a shard a grind instead of a find.
- `levels/README.md`: the legend gains `(`.

## Screenshots

In `/mnt/project-files/pass-140/`:
- `crown_lookout_shard.png`: the Crown Lookout, with the shard glowing magenta under the roof at top right, above the potion-shard platform.
- `meteor_rise_shard.png`: a Meteor Rise shelf with a Shade Knight; the shard is at the shelf's east end.

## Tests

- `test_economy.gd`:
  - `test_the_second_temper_costs_a_meteor_shard`: Temper I needs gold alone, Temper II reads "shards" and can't be bought without one, and a picked-up shard is carried. Buying spends one shard and the gold, and a new blade's second temper needs its own shard.
  - `test_the_world_holds_a_meteor_shard_for_every_blade`: at least as many shards in the levels as there are blades, one in the Tower, spread over at least four zones.
  - `test_the_forepaw_smith_tempers_a_blade_twice` now carries a shard for the second temper.
- `test_reachability.gd`: `(` is a pickup, so every shard must be reachable with the glove. All five are.
- `test_systems.gd`: the save round-trip sets `meteor_shards`.

Full suite: 2563 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98 | Unchanged. |
| Combat and enemies | 15 | 98 | The last unbuilt line of 5.2 is built: a blade's best temper now takes a find from the world, not only gold. |
| World and level design | 15 | 97.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.75 | Unchanged. |
| Audio | 5 | 97.75 | Unchanged. |
| Stability and performance | 5 | 97.75 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Weighted score: 95.9625 (up from 95.925). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

World, Systems, Audio, Stability and Faithfulness are tied at 97.75. World weighs the most (15), so pass 141 takes World.
