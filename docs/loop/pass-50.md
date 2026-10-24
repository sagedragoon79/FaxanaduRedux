# Pass 50: Conflate

Faithfulness (86) was the lowest category in play. Faxanadu is a string of towns between the dungeons, and the
Branches had none. This pass builds **Conflate**, the elves' town on the leaf road, at the end of the Canopy Bridge.

## What changed

- **Conflate** (`branches/conflate`, 44,-8, 80x23), through the Canopy Bridge's east gate (door 2). The bridge's sign
  now reads "Knock, and say who you are."
  - **Warden Faelan** at the gate. **The Guru** for rest, saving, skills and titles.
  - **Grocer Thessaly**, with Conflate Provisions: Elixir 1,500, Ointment 300, Jack Key 150, Mana Dew 1,000 (once)
    and Life Fruit 1,600 (once), per bible 10.2.
  - **Elder Aelwen**, who names the Bloom (Pakukame) on the crown-leaf above and points to the Elven Stride's shrine
    in the Windloft, up the north bough. That shrine is the next pass.
  - **Weaver Imra** (flavor: the dwarves who stopped climbing).
  - **Skywatcher Orin** up on a plank. Skywatch Charts sells the Chart of the Mist (500) and the Chart of the
    Branches (650). The Mist has no town, so its chart is sold here (new items `chart_mist` and `chart_branches`).
  - Two leaf-silk houses. The north bough's sign says it is roped off by the wardens.
- **Elves:** `castgen.py` NPC looks take `"ears": true`, a long ear swept back from the head. Every older sheet is
  byte-identical (checked).
- **Music:** `conflate`, a wistful harp waltz in E dorian (84 bpm, 3/4) with a soft pad and a breathy lead, and no
  drums. It is appended to `TRACKS`; older tracks are untouched.
- **Bible:**
  - 8.5: Pakukame's reward was "the Conflate gate opens". It now opens Conflate's north bough, the road up to
    Daybreak. The town is the zone's save and shop stop, so it should open on arrival; the boss gates the way onward
    instead.
  - 3.3: the Conflate cartographer.

## Tests

- `test_economy.gd`: `test_conflate_has_a_guru_a_grocer_and_a_skywatcher`.
  - All six townsfolk are present, and each has a sheet.
  - The grocer's stock is made of real items.
  - Both charts can be bought, both zones get charted, a Mist room shows dimmed, and the gold works out.
- `test_boss.gd`: `conflate` is a looping track, and the town plays it over the Branches ambience.
- `test_reachability.gd`: Conflate is in `MATTOCK_ROOMS`.

## Screenshots

`/mnt/project-files/pass-50/`: `conflate_west.png` (warden, Guru, house, grocer, elder) and `conflate_east.png`
(weaver, skywatcher on the plank, the north bough sign).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 87 | Unchanged. |
| World and level design | 15 | 91 | A town at the end of the leaf road. |
| Art cohesion | 15 | 84 | Unchanged (on hold). |
| Bosses | 10 | 87 | Unchanged. |
| Systems | 10 | 87 | Charts for two more zones. |
| Audio | 5 | 87 | A town theme. |
| Stability and performance | 5 | 85 | Unchanged. |
| Faithfulness | 5 | 88 | A Faxanadu town with its Guru and shops, elves and the Bloom's dread. |

Weighted score: 87.70 (up from 87.55).

## Lowest categories and next pass

Leaving Art aside (on hold), the lowest is Stability (85). The road on needs the **Elven Stride** (bible 4.1 A5,
6.5): the Windloft shrine up Conflate's north bough, where you win the air dash, and a first stride gate (a long
gap, or a mist curtain). Pair it with a stability item: a soak of the Branches with the stride in play.
