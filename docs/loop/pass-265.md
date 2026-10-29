# Pass 265: Mascon's tavern

Category: Faithfulness (last pass 257).

## Audit

I checked the remake's towns against the original's, using StrategyWiki's Faxanadu walkthrough (the "Misty town Mascon" page). The original's Mascon had a bar, a dried meat shop, an item shop, a key shop, houses whose people told of the Tower of Suffer, a hospital, and a Guru. The bar maid gave useful information, and a man at the back of the bar had "somewhat interesting" things to say.

The remake's Mascon had a Guru, a scribe, a grocer, a reedcutter and a ferryman. It had no bar. The other services are covered elsewhere:
- Victim and Dartmoor keep the keys (pass 209);
- Forepaw keeps the hospital and the meat (pass 175).

The bar was the one place in the original's towns built only to give the player word, and it was missing.

## Fix

- The house beside Mascon's Guru is now **the Black Water**, under a tavern sign: "Ale, eel stew, and whatever the barges heard".
- **Barmaid Brigid** stands at its door. She puts the Pendant in the far corner of the Matriarch's mire, past the east door. That is the remake's place for the original's Tower of Suffer prize. She also puts Zorugeriru round the Spring of Mist, past the Dry Cistern.
- **Old Cormac**, an ore-barge poler for forty years, stands beside her. He names the messenger's boots at Feather Hollow by Victim, and warns of the Sunken Chapel.
- Both have other words once the Tree blooms. Their sheets come from `castgen.py`. The scribe moved two tiles east to make room.
- Test: `test_mascon_keeps_the_originals_tavern` (`test_economy.gd`). It checks three things:
  - both stand in Mascon by a house under the tavern sign;
  - both have their say, and another after the bloom;
  - each thing they tell is true of the rooms: the Pendant's room, the mire as Mascon's east door, Zorugeriru's spring past the Cistern, and Feather Hollow by Victim.
- Screenshot, looked at: `/mnt/project-files/pass-265/tavern.png`. My first placement put the tavern over Mascon's drowned boardwalk, which is a spike dip until the Spring of Mist flows. I moved it onto the town's floor.
- Bible: the Mascon's tavern paragraph in 10, and the 15.3 Faithfulness checklist.

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
| Faithfulness | 5 | 99 | Unchanged score: the original's Mascon bar and its word. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 266 takes Combat (last pass 258).
