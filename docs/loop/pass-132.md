# Pass 132: Death, the original's last spell

Faithfulness (97.25, weight 5) was the lowest category apart from Art. I checked the original's spells, items, keys and places against what the remake has built.

| The original | The remake | Verdict |
| --- | --- | --- |
| Swords, armor and shields by their names (Hand Dagger to Dragon Slayer, Leather Armor to Battle Suit, Small Shield to Battle Helmet) | all in `data/items.json`, under the same names | fine |
| Jack, Queen, King, Ace and Joker keys | all five, each with its own vault (pass 117) | fine |
| Wing Boots, Mattock, Black Onyx, Hour Glass, the four rings | all built | fine |
| Pendant, Magical Rod | left out on purpose (not in the bible) | fine |
| Ladders | built (passes 124, 125) | fine |
| **Magic: Deluge, Thunder, Fire, Death, Tilte** | Four built. **Death**, the original's darkest spell, was in bible 4.1 ("screen-wide, very expensive, late secret") and in the Arcana tree's Mantra of Death node, but was never built. | **built** |

## As built (bible 4.1)

- **Death** (`DeathWave`, `Spells.DATA.death`):
  - It costs 40 MP of a base 60, so it is one cast from a full flask.
  - A ring of black light with a violet rim rolls out from you to 300 px over 0.45 s, through walls.
  - Every foe it passes takes one blow of 36. It falls from everywhere at once, so no shield faces it.
  - Bosses take half, 18.
  - It shakes the screen a little and tolls a deep knell over a dark swell (`death_wave`, rendered with `sfxgen.py`, -14.8 dB RMS; `levels.py --check` passes).
  - It comes last on the Next Spell cycle.
- **The Death scroll** (legend `{`):
  - It is a parchment bound in black, with a skull glyph that breathes.
  - It lies in the King's Kennels in Dartmoor, beside the kennel-master's chest on the loft that only the hidden planks reach. Those planks are unseen until the Black Onyx shows them, and the scroll comes late, as the bible asks.
  - The reachability checker and Treasure Sense count it.
- **Still to come:** Mantra of Death, the Arcana node that halves its cost.

## Screenshots

In `/mnt/project-files/pass-132/`:
- `death_ring.png`: Death cast in the King's Kennels. The ring is halfway out, and the two Clockwork Hounds flash with the blow.
- `death_scroll.png`: the scroll on the loft beside the chest.

## Tests

In `test_combat.gd`:
- `test_death_strikes_every_foe_around_through_walls`:
  - it costs 40 MP and is on the Next Spell cycle;
  - it tolls;
  - the foe beside you takes 36, once;
  - a boss beyond a wall takes 18;
  - the ring is then gone, and there is not enough MP left for a second cast.
- `test_the_death_scroll_is_a_late_secret`: legend `{` is the scroll, it lies in the King's Kennels, and a new game starts without it.

`test_reachability.gd` reaches the scroll.

## Bible

Section 4.1, the supporting spells: Death as built.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.5 | Unchanged. |
| Combat and enemies | 15 | 97.5 | Unchanged. |
| World and level design | 15 | 97.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.75 | All five of the original's spells are in. |

Full suite: 2497 checks, all passing, with no script errors in the log.

Weighted score: 95.7 (up from 95.675). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Combat, World, Systems, Audio and Stability are tied at 97.5. Movement weighs the most, so pass 133 takes Movement.
