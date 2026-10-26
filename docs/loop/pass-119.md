# Pass 119: the Marsh Hag

Combat (96.5) tied for lowest apart from Art. Bible 7 had two planned foes left: the Marsh Hag (the Mist) and the Spire Sentinel (Daybreak). The bible put the Marsh Hag first.

She is also the Mist's missing piece. Its other foes all come to you or wait for you:
- the Lantern Ghost lunges;
- the Bog Myconid bursts when you come close;
- the Drowned Dwarf rises and shambles after you.

Nothing in the Mist made you go to *it*. The zone's whole idea is seeing only what is lit. A foe that stays back in the fog and harries you from afar, but carries a light, makes that idea the fight.

## As built

**Marsh Hag** (`MarshHag`, legend `?`):
- **Look:** a bent crone of the drowned villages in a shawl of dry reeds, moss for hair and a long hooked nose, leaning on a crooked willow staff. A green marsh-wisp is caught in the staff's crook. The wisp is a light (group `light`, 40 px, 64 px while she hexes), so she shows through the fog from far off.
- **Range:** she spots you from about 15 tiles and shuffles nearer at 22 px/s until you are within 11, her hex range.
- **Keeps her distance:** come within four tiles and she backs away at 34 px/s, still facing you. After 1.2 s, or at a wall or an edge, she stands and hexes anyway.
- **The hex (the telegraph, 0.6 s):**
  - She draws herself up and raises the staff, and the wisp flares. She pulses white, and you hear her cackle over welling bubbles (`hag_hex`).
  - A ring of bubbling green bog light marks the floor or plank under your feet (`MireGrasp`). It is a light too, so you can see it in the fog.
- **The strike:** a hand of black mud bursts up out of the mark for 12 and can't be parried (`mire_grasp`). Step off the mark and it misses.
- **Breaking it:**
  - Strike her mid-hex and the spell breaks. The mark fizzles and the staff clatters into the mud (`hag_fumble`).
  - She gropes for the staff for 1.0 s, taking every blow at half again, the breaking blow included.
  - So the answer is to close in through the fog, toward her light.
- **Stats:** 30 HP, contact 6, hexes every 1.6 s, 8 to 12 gold, 18 XP.

**Art:** a castgen sheet (`marsh_hag`: idle, walk, hex, cast, fumble, stagger) at 2x. The wisp and the mud hand are drawn in code.

**Sounds:** `hag_hex`, `mire_grasp` and `hag_fumble` (`sfxgen.py`), at -19 dB RMS. `levels.py --check` passes. I checked out the 11 unrelated sound effects that `sfxgen.py` rewrote.

**Placed:**
- the Fog Cut, on the far side of the dip, so she hexes you as you cross it;
- the Victim Causeway, on a plank over the dip, out of a slash's reach until you climb to her.

## Screenshots

In `/mnt/project-files/pass-119/`:
- `hex_mark.png`: she pulses white on her plank over the Victim Causeway with the wisp flaring, and the bog-light ring is under the player's feet.
- `hex_mark_in_the_pit.png`: the same from the spiked dip, with the mark among the spikes.
- `mud_hand_strikes.png`: the hand bursting up under the player.

## Tests

In `test_enemies.gd`:
- `test_marsh_hag_hexes_the_mire_under_your_feet`:
  - her wisp is a light;
  - the mark is under your feet on the floor;
  - the hex lasts at least `MIN_TELEGRAPH` and pulses;
  - the hand does 12;
  - she hexes again;
  - stepping off dodges it;
  - a parry doesn't turn it.
- `test_striking_the_marsh_hag_mid_hex_breaks_the_spell`:
  - the breaking blow lands at half again;
  - she fumbles and the mark fizzles;
  - no hand comes up;
  - the next blow also lands at half again;
  - the fumble lasts about 1 s.
- `test_the_marsh_hag_backs_away_when_you_close_in`: she backs away while facing you, then hexes anyway.
- The sound audit and the newer foes' voices test cover her three sounds.

## Bible

- Section 7, the Mist row: the Marsh Hag as built.
- Section 7, the "Not yet built" row: only the Spire Sentinel is left.
- `levels/README.md`: legend `?`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96.5 | Unchanged. |
| Combat and enemies | 15 | 97 | The Mist gains a foe you have to go to, and she plays on the fog itself. Her hex reads by sight (the mark, the flaring wisp) and by ear, and breaking it rewards closing in. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 96.5 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.75 | Unchanged. |

Full suite: 2340 checks, all passing.

Weighted score: 95.15 (up from 95.075). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Audio and Stability are tied at 96.5. Pass 120 takes Stability and performance: a frame-budget check of the newest rooms and foes (the card vaults, the Threshold pocket and the Marsh Hag's lights in the fog).
