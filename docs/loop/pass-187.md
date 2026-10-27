# Pass 187: every find is counted

All categories except Art are tied at 99, and World's last pass (178) was the oldest, so pass 187 takes World. I audited the world (bible 3 and 11) against the newest content (passes 178 to 186).

| Check | Finding | Verdict |
| --- | --- | --- |
| The Rune Dagger (pass 184) | It lies on the Hornet Gallery's floor, it is reachable, and it is a treasure (legend `}` is in `World.TREASURE_CHARS`) | fine |
| The Matriarch's Mire (pass 179) | It is reachable, guarded and counted among the guardians | fine |
| Kept gear and the helmet slot (passes 185, 186) | The Equipment page works anywhere, and no room needs a shield, so nothing in the world depends on what you wear apart from the Battle Suit (secret ending) and the Dragon Slayer (the heart) | fine |
| **Finds laid by props** | The Battle Helmet (`zenis/threshold`) and the Joker Key (`dartmoor/drowned_market`) are laid by `prop:` lines, not grid characters. The World catalog built its treasure list from grid characters only, so neither counted toward the percent, the Journey's Treasures row or Treasure Sense. That held even though the helmet sits in a hidden pocket, the kind of find Treasure Sense exists to point at. | **fixed** |

## As built

- `Room.FOUND_PROPS` lists the props that lay a find: `joker_key` and `battle_helmet`.
- `World.build_catalog` adds a treasure for each such `prop:` line, using the id the room gives the pickup (`room:x,y`, the prop's own cell). So the percent, the Journey's Treasures row and the map's Treasure Sense mark now count them, and taking the item counts it as found.
- Bible 11 (the completion rows) now says so.

## Tests

- `test_systems.gd`, `test_finds_laid_by_props_count_as_treasures` (new):
  - the helmet is a Threshold treasure, and the Joker Key a Drowned Market one;
  - the pickup carries the same id;
  - taking the helmet adds one to the percent's treasures, and Treasure Sense stops counting it.

Full suite: 3471 of 3471 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged: every find in the world is now counted and sensed. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 188 takes Bosses (last pass 179, now the oldest).
