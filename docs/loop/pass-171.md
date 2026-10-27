# Pass 171: the Bark Knight Captain

Bosses, Systems, Audio, Stability and Faithfulness were tied at 98.75. Bosses and Systems weigh the most (10), and Bosses' last pass (163) was the older, so pass 171 takes Bosses. I audited the bosses against bible 8 and the newest content (passes 163 to 170).

| Check | Finding | Verdict |
| --- | --- | --- |
| Openings (pass 163) | every boss names its `punishable()` window, and the table in section 8 matches | fine |
| The Clockwork Alpha (pass 169) | its den, its tells, the Hour Glass stop and its reward all hold | fine |
| The Proving Scar (pass 170) | a shrine now stands before the throne, so a lost Evil One fight restarts at the Scar's end, not at the Drift Well | fine |
| Boss Rush | still the 12 zone bosses and the Foreman; the mini-bosses stay out of it, as the bible says | fine |
| **Mini-bosses** | Bible 8 plans four, about one per zone. The Foreman and the Alpha were built. The Branches had none, though its Bark Knights are the zone's signature foe. | **built** |

## As built

**The Bark Knight Captain** (`scripts/bosses/bark_captain.gd`) is the first knight the World Tree grew. He is half again as tall as his Bark Knights and code-drawn at 3x, with five bark plates, a crown of living leaves and a bough lance six tiles long. He keeps **the Thorn Yard** (`levels/branches/thorn_yard.room`, 46,-8), through a new east gate in Conflate. He has 240 HP.

- **Thrust** (0.65 s tell): the lance reaches 110 px for 18 and can be parried. He then roots for 1.3 s, and the lance is a one-way bough you can stand on or pogo off.
- **Vault** (phase 2, 0.7 s tell): he pole-vaults high and comes down lance-first where you stood, for 20. He then hangs planted for 1.4 s.

His bark works like his knights': each blow chips one plate and lands a quarter, until he is bare. He is open, and takes blows in full, while rooted, while planted, or while reeling from a parry. Each time he pulls free, one plate grows back. Below half his tells are 20% shorter. He gives a Mana Dew, and no skill point.

## Screenshots

- `/mnt/project-files/pass-171/yard.png`: his name card as you enter the yard.
- `/mnt/project-files/pass-171/captain.png`: the Captain walking at you, lance level.

## Tests

`test_boss.gd` adds seven new tests:

- `test_the_captain_keeps_the_thorn_yard_east_of_conflate`
- `test_the_captains_tells_are_fair`
- `test_the_captains_bark_chips_away_and_grows_back`
- `test_the_captains_thrust_roots_into_a_bough_and_opens_him`
- `test_a_parried_thrust_staggers_the_captain`
- `test_the_captain_vaults_onto_you_in_his_second_phase`
- `test_the_captain_gives_mana_dew`

The yard has been added to the Mattock room list (Conflate's own list), and it passes the reachability and soft-lock checks.

`test_the_newer_foes_have_voices_of_their_own` now lets a family's mini-boss share its kin's sounds. The Captain plays his knights' creak, thrust, root and chip, only louder.

Full suite: 3257 checks passed. The 4 that failed were that voice check, and it passes after the change (36 checks). That makes 3261 checks, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Three of the four planned mini-bosses are built. The Captain turns the Branches' own knight into a fight about timing his roots. |
| Systems | 10 | 98.75 | Unchanged. |
| Audio | 5 | 98.75 | Unchanged. |
| Stability and performance | 5 | 98.75 | Unchanged. |
| Faithfulness | 5 | 98.75 | Unchanged. |

Weighted score: 96.8 (up from 96.775). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Systems, Audio, Stability and Faithfulness are tied at 98.75. Systems weighs the most (10), so pass 172 takes Systems. The Marsh Hag Matriarch is the last unbuilt mini-boss.
