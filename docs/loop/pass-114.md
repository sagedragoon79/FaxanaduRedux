# Pass 114: the Seed Bomber

Combat (96) was tied for lowest apart from Art. Three foes were still planned in bible 7: the Seed Bomber (Branches), the Marsh Hag (the Mist) and the Spire Sentinel (Daybreak). This pass builds the first. The bible named it but had no description, so this pass designs it.

## Design

The Branches already test you on the ground: the Leaf Mantis lunges along a bough, and the Bark Knight thrusts his lance. What they lacked was a threat from above that turns the open sky against you. The Seed Bomber does that.

Its answer had to be new as well. The game already has:
- a parried shot that flies back (the Storm Harpy's feathers, the Gear Bat's gear);
- a ground hazard you step around (the Meteor Slug's embers, the Bog Myconid's spores).

The Seed Bomber's seed asks for a **strike**. Any blow sends the seed back up into the bird, whether it is still falling or already sputtering on the branch. That brings a bird you can't reach down to you. Stand your ground and swing at the right moment, and it falls. Panic and run, and the thorns catch you.

## As built

**The bird** (`SeedBomber`, legend `;`): a pod-bellied canopy bird with leaf wings, a leaf crest, a hooked gold beak and a bark husk of seeds for a belly.
- **Stats:** 28 HP, touch damage 8.
- **Hover:** within 240 px it keeps 84 px over your head, out of reach of a plain slash, flying at up to 72 px/s.
- **Tell:** right over you (within 16 px), it squeezes for 0.5 s. Its wings go up, its belly swells and glows gold, it shivers and flashes white, and `seed_rattle` plays.
- **Drop:** a seed (`seed_drop`), then 1.8 s before the next.
- **The husk:** it hangs open for a moment after each drop (the `empty` animation).

**The seed** (`BomberSeed`):
- Falling, it stings for 10 whoever it lands on.
- It sticks on solid ground or a one-way plank crossed from above, then sputters for 0.6 s. Its seams blink faster, it swells, and its reach shows as a faint ring. `seed_fuse` plays.
- Then it bursts in thorns: 12 to anything within 28 px. The burst can't be parried (a held guard still softens it). `seed_burst` plays.
- **Strike it**, falling or sputtering, or **parry it** as it falls, and it flies straight back into its bird at 320 px/s.
  - There it bursts for 18 and knocks the bird out of the sky.
  - The bird lies dazed on its back for 1.4 s, taking every blow at half again, then climbs back up.
  - A seed sent back hurts nothing else.
- It is a pogo target. The Hour Glass holds it still.

**Art:** a castgen sheet at 2x (`seed_bomber`) with six animations: fly, windup, drop, empty, downed and stagger. The seed is drawn in code in the husk's colors.

**Sound:** four new sounds from `sfxgen.py`: `seed_rattle`, `seed_drop`, `seed_fuse` and `seed_burst`.
- `levels.py --check` passes (94 sound effects). The new sounds sit at an RMS of -15 to -21 dB, against a median of -17.7.
- `sfxgen.py` again rewrote nine unrelated files with tiny byte diffs, so those were checked out.

**Placement:**
- Thicket Road (34,12), over the thorn pit, so you cross it under falling seeds.
- North Bough (30,16), in the middle of the climb.
- Reachability passes.

## Screenshots

In `/mnt/project-files/pass-114/`:
- `overhead.png`: in Thicket Road, the bird has found the player and keeps over their head.
- `seed.png`: a seed falling beside the player.
- `squeeze.png`: the squeeze, washed white (the telegraph). The Bark Knight's brace flashes at the same moment.
- `sheet.png`: the sheet, enlarged.

## Tests

In `test_enemies.gd`:
- `test_seed_bomber_hangs_over_you_then_squeezes_and_drops_a_seed`:
  - it squeezes from right over your head, more than 63 px above;
  - the tell lasts at least `MIN_TELEGRAPH` and flashes;
  - the seed it drops stings.
- `test_a_seed_on_the_branch_sputters_then_bursts_in_thorns`:
  - the seed sticks on the floor;
  - it sputters for at least `MIN_TELEGRAPH`;
  - the burst reaches 22 px, and a parry tap doesn't turn it.
- `test_a_struck_seed_flies_back_and_knocks_the_bomber_down`, through a real player slash:
  - the seed returns and deals 18;
  - the bird falls to the floor and takes 6 from a 4-damage blow;
  - it lies dazed about 1.4 s, then flies again.
- `test_a_parried_seed_flies_back_at_its_bird`: no damage, and the seed returns.
- `test_the_newer_foes_have_voices_of_their_own` now covers the four seed sounds.
- `test_every_attack_tell_and_strike_has_a_sound` counts `downed` and `rise` as calm states.

## Bible

- Section 7: the Seed Bomber's entry in the Branches (Conflate) row. The planned list is now the Marsh Hag and the Spire Sentinel.
- Audio: the Seed Bomber's sounds are added to "Foe voices".
- `levels/README.md`: legend `;`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96 | Unchanged. |
| Combat and enemies | 15 | 96.5 | The Branches get a threat from above, with a new answer: strike its seed back to bring it down. Two planned foes remain. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 96.5 | Unchanged. |
| Audio | 5 | 96 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Full suite: 2234 checks, all passing.

Weighted score: 94.875 (up from 94.8).

## Next

Movement and Audio are tied at 96 for lowest apart from Art. Pass 115 takes Movement.
