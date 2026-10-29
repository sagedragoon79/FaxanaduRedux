# Pass 249: the spring keepers

Category: Faithfulness (last pass 241).

## Audit

I checked the bible's faithfulness list against the original: the eight towns and their Gurus, the rank titles, the rings, the card keys, the spells, the relics, Fraternal Castle and King Grieve's Dragon Slayer. All of them are held by `test_the_faithfulness_checklist_is_all_here`. I then read StrategyWiki's walkthrough of the original's three springs. In the original, a man stands before each spring, and the spring wakes with him:
- the Spring of Trunk needs an Elixir;
- the spring in the sky has a keeper who dozes off and is woken with water;
- the third spring's keeper revives it once you reach him.

In the remake the three springs (Trunk, Mist, Sky) were stone fountains pressed with Up, with no one standing at any of them. The springs are the heart of the story (each fills a third of Eolis's fountain), so this was the most visible thing from the original that was missing.

I set aside two other candidates because the sources were unclear: the original's tower names (Tower of Fortress, Tower of Suffer, Tower of Mist) and the third spring's name.

## Fix

- Six NPC entries in `data/npcs.json`: three keepers, each with a `_glad` self for once the spring flows. Both selves have a word once the Tree blooms (`test_the_town_speaks_of_the_blooming_tree` asks it of everyone). Their sheets come from `castgen.py`.
  - **Odran**, a dwarf in water-blue, at the Spring of Trunk. He tells the original's riddle: his father swore it took an Elixir.
  - **Ilka**, of Victim, at the Spring of Mist once Zorugeriru is beaten. The keeper is never in the fight.
  - **Arel**, an elf, at the Spring of Sky, the original's dozing keeper, there once Borabohra is beaten.
- Each spring room has two `npc:` lines, one for the dry spring and one for the flowing spring.
- Test: `test_every_spring_has_its_keeper` (`test_rooms.gd`). It checks that:
  - each keeper and their glad self are one person with sheets;
  - no keeper stands in a guardian's arena before the win;
  - the keeper waits while the spring is dry, and the glad one stands there once it flows.
- Screenshots (all looked at, each keeper on the floor beside the spring): `/mnt/project-files/pass-249/trunk_keeper.png`, `mist_keeper.png`, `sky_keeper.png`.
- Bible 4.4: "The spring keepers", with the deviation that clearing a spring stays the player's act and asks for no Elixir.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: each spring has its keeper again. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 250 takes Combat (last pass 242).
