# Pass 145: Victim, the lamp town

Faithfulness (97.75, weight 5) was the lowest category apart from Art. I audited the remake against the original Faxanadu, bible 1, 2 and 16, and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Pillar 3: "the towns and Gurus, the rings and keys, the ranks and titles, the springs and the Evil One" | Rings, keys (all five cards), ranks and titles named by the Guru, three springs and the Evil One in three phases are all built | fine |
| Items and magic | Every blade, armor and shield tier, the Mattock, Wing Boots, Black Onyx, Hour Glass, Elixir, Ointment, Poison and all five spells are built. The Pendant and Magical Rod stay out on purpose (not in the bible) | fine |
| Meteor Shards (pass 140) | A splinter of the meteor that drives the story, spent at the dwarf smith: in keeping with the original's dwarves and its meteor | fine |
| The post-game bloom (pass 141) | Bible 2 ends "The Tree blooms again", and now the world shows it | fine |
| Wanderer's Grace (pass 142) | A skill-tree capstone, a modern system the bible asked for (pillar 3: "replace ... grinding with modern systems") | fine |
| 16: names and music | Names kept from the original; all themes new | fine |
| **Towns** | The original has eight towns: Eolis, Apolune, Forepaw, Mascon, Victim, Conflate, Daybreak and Dartmoor. Pillar 3 promises to keep them, and bible 3.2 lists "Victim, Mascon" for the Mist. Neither was built. Victim was only a name on a causeway sign ("VICTIM, WEST"), and 3.3 said "the Mist has no town of its own". So the Mist (11 rooms) was the only zone the bible gives a town that had none: no warm pocket, no Guru and no shop. Bible 10.2's key master in Victim had no town to stand in. | **built (Victim)** |

## As built

- **The room:** `levels/mist/victim.room` (25,-8, 80x23), through a new west door on the Feather Hollow's shelf (rows 13-15). It is reached with the Lantern Key, through the room where the Wing Boots wait. A raised landing at the east end steps down to the boardwalk street.
- **People:**
  - a **Guru** (save, skills, and a stop on the Mantra Path);
  - **Keymaster Odo** (`victim_keys`): Jack 150 g, Queen 400 g, ointment 300 g and elixir 1,500 g. The Queen opens the Feather Hollow's vault next door;
  - **Fogwalker Bram** on a plank loft (`victim_charts`): the Mist chart, 500 g;
  - **Marta**, a miner's widow: Victim's miners dug meteor stone for the dwarf king's gold and came back up the drowned stair as the Drowned Dwarves of the mire;
  - **Lamplighter Nell**, who lights every lamp twice because dusk and dawn look the same in the fog.

  Marta and Nell have `lines_cleared` for after the ending. Sheets come from `castgen.py`.
- **Light in the fog:** the town's fog is 0.6 (the marsh's is 0.88). Four lamp posts (prop `lamp`, the new `TownLamp`: a lantern on an iron arm, in the `light` group with an 84 px radius) burn pockets out of it, with dark between, as the bible's tone asks ("towns are warm pockets of light"). Houses in the Mist take a `mist` style (reed-grey planks, a dark damp frame), and their windows burn from the first visit, since Victim's people never left.
- **Music:** `victim`, the Mist's B minor waltz come in out of the cold. It is in D major, 3/4 at 84: the music-box pluck on two and three, warm pads, a walking bass and a lamp-bell on every other downbeat. Peak -1.4 dB, RMS -14.7 dB (music median -14.7); `levels.py --check` passes.
- **Mascon**, the Mist's second town, is still planned. The Scorched Hall's sign already points east to it.

## Screenshots

In `/mnt/project-files/pass-145/`:
- `victim_west.png`: the sign, a lamp post, the Guru, a boardwalk house with a lit window, the keymaster and Marta, with fog between the lamps.
- `victim_east.png`: the lamplighter, Fogwalker Bram on his loft, and the landing up to the Feather Hollow door.

## Tests

- `test_economy.gd`, `test_victim_has_a_guru_a_keymaster_and_a_fogwalker`: every person stands in the room with a sheet, and the two talkers have lines and post-game lines. The key master's stock is real items at bible 10.1's prices: you buy a Queen Key and the chart for 900 g. The Guru joins the Mantra Path.
- `test_world.gd`, `test_victims_lamps_burn_pockets_in_the_fog`: the lamps and lit mist houses are there, and the fog lies thinner than the marsh's. A lamp is a fog light of at least 80 px that clears the street under it, while 170 px away stays dark. The Feather Hollow's west door leads to Victim.
- `test_reachability.gd`: `mist/victim` joins the Mattock rooms. The bound-fog test checks that Victim needs the Lantern Key, and `test_everyone_in_victim_can_be_reached` checks that every person, the loft too, can be reached with nothing past the key.
- `test_boss.gd`: `victim` loads as a loop, and the room plays it over `amb_mist`.

Full suite: 2673 checks, all passing, with no script errors in the log.

## Bible

- 3.2: a **Victim (pass 145)** block.
- 3.3: the Mist has a cartographer of its own.
- 10.2: Victim's key master as built.
- `levels/README.md`: the `lamp` prop.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98 | Unchanged. |
| Combat and enemies | 15 | 98 | Unchanged. |
| World and level design | 15 | 98 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98 | Unchanged. |
| Audio | 5 | 98 | Unchanged. |
| Stability and performance | 5 | 98 | Unchanged. |
| Faithfulness | 5 | 98 | Victim stands; Mascon is the one town still to build. (Corrected in pass 148: this first said seven of eight towns stood. Dartmoor is a drowned city with no Guru or shop, so with Victim it was six.) |

Weighted score: 96.0625 (up from 96.05). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Combat, World, Systems, Audio, Stability and Faithfulness are tied at 98. Movement weighs the most (20), so pass 146 takes Movement.
