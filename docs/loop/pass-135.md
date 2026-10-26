# Pass 135: cracked-stone caches

World (97.5, weight 15) was tied for the lowest category apart from Art, and weighs the most of the tied ones. I counted each zone's secrets and pickups against the bible 11 table.

| Secret | Built | Bible 11 | Finding |
| --- | --- | --- | --- |
| Hidden rooms | 11 | every zone (pass 131) | fine |
| Lore tablets | over 100 signs | 12 | fine |
| Mantra Shards | 16 | 15 | fine |
| Potion Shards | 18 | 9 | fine |
| Life Fruit | 12 | 14 | close |
| Mana Dew | 7 | 9 | short, and none past the Mist |
| **Cracked stone (Mattock)** | **9 rooms: 7 in the Tower, 1 in the Trunk, 1 in Dartmoor** | 18 walls | **The Mattock's backtracking payoff stopped at the Tower. The Mist, the Branches and Daybreak never asked for it, and nothing in Eolis or the early rooms showed a crack to come back to.** |

## As built (bible 11)

Four caches behind cracked stone. In each, the prize is in plain sight through the gap, so the player sees what they're missing:

| Room | Where | Prize |
| --- | --- | --- |
| West Gate (Eolis) | a niche in the town wall, three steps from where a new game starts | Life Fruit |
| Scorched Hall (the Mist) | on the east shelf, beside its Life Fruit | Mana Dew |
| North Bough (the Branches) | a niche on the west wall, above the Bounce-pod climb | Mana Dew |
| Spire Foot (Daybreak) | hollowed into the stone block west of the conduit gate | Mantra Shard |

- The West Gate's fruit is the first thing the game shows you that you can't have yet. It opens once the Foreman gives up the Mattock.
- The other three are in zones you reach with the Mattock, so they reward the habit of striking the crack.
- Mana Dew comes to the table's 9, and Life Fruit to 13. The new spawn tile in the West Gate is three tiles east.

## Screenshots

In `/mnt/project-files/pass-135/`:
- `eolis_west_gate.png`
- `scorched_hall.png`
- `north_bough.png`
- `spire_foot.png`

Each shows the cracked face with its prize behind it.

## Tests

- `test_every_large_zone_hides_something_behind_cracked_stone` (`test_rooms.gd`), new: every zone of five rooms or more, except Zenis, has cracked stone. Before this pass it failed for Eolis, the Mist, the Branches and Daybreak.
- `test_mattock_secrets_need_the_mattock` (`test_reachability.gd`), new: the West Gate's fruit is out of reach without the Mattock and in reach with it.
- The reachability checker reaches all four prizes with the Mattock.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.75 | Unchanged. |
| Combat and enemies | 15 | 97.75 | Unchanged. |
| World and level design | 15 | 97.75 | The Mattock keeps paying off across the world, starting from the first room. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Full suite: 2516 checks, all passing, with no script errors in the log.

Weighted score: 95.825 (up from 95.7875). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Systems, Audio and Stability are tied at 97.5. Systems weighs the most (10), so pass 136 takes Systems.
