# Pass 148: Mascon, the stilt town on the black water

World (98, weight 15) was the lowest weighted category apart from Art. I audited the world against bible 3, 4 and 11 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 3.2 zones and rooms | every zone built, the Sunken Spring and two Guru Trials included | fine |
| 4.4 world-state changes | every row built through the post-game bloom (pass 141) | fine |
| 11 secrets | hidden rooms per zone, cracked-stone caches and Meteor Shards (passes 131, 135, 140) | fine |
| Victim (pass 145) | reached with the Lantern Key, its people all reachable | fine |
| Rare drops (pass 147) | foes in every zone can leave them; they wait on the floor like bread | fine |
| Shaft doors (pass 146) | the fix holds in every shaft the soaks cross | fine |
| **3.1 and 10.2: Mascon** | Bible 3.1 draws "[3b Mist Marsh - Mascon]", 3.2 lists "Victim, Mascon" for the Mist, and 10.2 puts a spell-scroll shop in Mascon. Since pass 33 the Scorched Hall's sign has said "The Mascon road runs on east under black water. When the spring flows, the marsh will give it back." Nothing was ever behind it. It was the last town the bible planned and hadn't built. | **built** |

## As built (bible 3.2, 4.4, 10.2)

- **The way down:** a 3-wide shaft in the Scorched Hall's floor beside that sign (door 3) drops down a ladder onto the Mascon road (`levels/mist/mascon.room`, 33,-6, 80x23, under the Scorched Hall and the Dry Cistern). The ladder climbs back out.
- **The black water:** east of the landing the road is a 20-tile dip over spikes, spanned by drowned boardwalks (`b`) that rise with the Spring of Mist, as on the Fog Cut and the Victim Causeway. Before the spring, the reachability checker finds one way over: pogo along the spikes with the Mattock, then climb the far side with the Glove. That is a skill route, like the Storm Ledge's, so it stays open.
- **The town:**
  - a Guru (save, skills, Mantra Path stop);
  - **Scribe Orla** (`mascon_scrolls`), selling Fire for 1,200 g, the same price as Daybreak's scribe (bible 10.2 always listed Mascon for the scroll shop);
  - **Eelwife Brannagh** (`mascon_items`), selling ointment, elixir and Jack Keys;
  - **Old Teague the Poler**, who poled the dwarf king's ore barges down this road until the king wanted only meteor stone. He has post-game lines.
- **Look and sound:**
  - Mist-style lit houses, three lamp posts (`TownLamp`), and fog at 0.6.
  - Music `mascon`, a poler's song: E dorian in 3/4 at 72, a plucked line over an open-fifth drone, a drum stroke on each downbeat. Peak -0.7 dB, RMS -14.8 dB (music median -14.8). `levels.py --check` passes.
- **Towns now:** seven of the original's eight towns stand with a Guru and shops. Dartmoor is the drowned city itself, with no Guru or shop. Pass 145's note that "seven of eight" stood then was wrong, and is corrected in its log.

## Screenshots

In `/mnt/project-files/pass-148/` (both with the spring restored):
- `mascon_road.png`: the landing at the ladder's foot, the road sign, and the risen boardwalk across the black water to the town's sign.
- `mascon_town.png`: the Guru, two lit stilt houses, Orla, Brannagh, Teague and the lamps.

## Tests

- `test_economy.gd`, `test_mascon_has_a_guru_a_scribe_and_stores`:
  - everyone stands in the room with a sheet, and Teague has lines and post-game lines;
  - the stores sell real items;
  - Orla's Fire is 1,200 g and teaches the spell, and Daybreak's scroll then shows as owned;
  - the Guru joins the Mantra Path.
- `test_reachability.gd`:
  - `mist/mascon` joins the Mattock rooms;
  - `test_mascon_lies_across_the_black_water` checks the following. Before the spring the boardwalks are no footing, the landing is reached, and the ladder climbs back to the Scorched Hall. With the spring they are footing. Every person can be reached before and after.
- `test_boss.gd`: `mascon` loads as a loop and plays in the room over `amb_mist`.

Full suite: 2726 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.25 | Unchanged. |
| Combat and enemies | 15 | 98.25 | Unchanged. |
| World and level design | 15 | 98.25 | The last planned town is built, and the Scorched Hall's oldest promise is kept. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98 | Unchanged. |
| Audio | 5 | 98 | Unchanged. |
| Stability and performance | 5 | 98 | Unchanged. |
| Faithfulness | 5 | 98 | Unchanged. |

Weighted score: 96.1875 (up from 96.15). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Systems, Audio, Stability and Faithfulness are tied at 98. Systems weighs the most (10), so pass 149 takes Systems.
