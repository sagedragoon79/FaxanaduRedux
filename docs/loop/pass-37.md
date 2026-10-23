# Pass 37: Ripasheiku, the Lantern Widow

Bosses was lowest at 78. Pass 36 built the Mist's fog, which makes the bible's third boss possible: a spider-wraith
who is seen only where her lanterns glow (bible 8.3).

## What changed

- **The Sunken Chapel** (`mist/sunken_chapel`, 30,-7, 60x23).
  - It lies past a new east door in Lantern Landing.
  - It is a drowned nave under thick fog (`fog: 0.92`), with side ledges, a high central ledge and stone ribs.
  - The doors seal while she lives.
- **Ripasheiku** (`scripts/bosses/ripasheiku.gd`). She is code-drawn at 2x, with a bulbous abdomen, a hooded head and
  eight jointed legs, and four lanterns hung on her legs.
  - **Lanterns** (`scripts/bosses/boss_lantern.gd`, a `BossSegment`). Each is a hitbox and a light in the fog.
    - One blow breaks a lantern and costs her 18 HP.
    - The freed soul clings to her as pale fire, so she shows more: 8% at first, 16% more for each lantern.
    - Her tells always show at least 80%, so they stay fair in the murk.
  - **Phase 1**: she stalks you in the dark, then either sweeps her front legs or pounces at where you stand.
  - **Phase 2** (below 66%): she climbs to the vault and hangs there.
    - **Web**: a thread flickers toward you, then a strand shoots along it. If it catches you, it reels you toward her
      (the new `Player.pull`). A dash breaks free.
    - **Drop**: she shivers over a shadow, then falls. She lies stunned for 1.3 s and takes 1.5x damage.
  - **Phase 3** (below 30%, or all lanterns broken): she comes down for good. She is fully visible and fast, with tells
    a quarter shorter, but never under the minimum.
  - **Reward**: the Lantern Key, Mana Dew and a skill point (`BossArena.BOSSES`).
- **Fog**: lights in the group `light` are now lit wherever the camera is. A boss's moving lanterns no longer blink out
  while the camera catches up.
- Bible 8.3 now records the built fight. A new 4.4 row records her defeat.

## Tests

`test_boss.gd` has six new tests:

- `test_sunken_chapel_wakes_the_lantern_widow`: she wakes across the chapel, and her four lanterns are lights.
- `test_ripasheiku_telegraphs_are_fair`: every tell in every phase is at least `MIN_TELEGRAPH`.
- `test_breaking_her_lanterns_shows_more_of_her`: a lantern shatters, hurts her and shows more of her. Breaking all
  four starts phase 3, with her in plain sight.
- `test_ripasheiku_climbs_and_reels_you_in_on_a_web`: phase 2 climbs to the vault, and a web catches the player and
  pulls them toward her.
- `test_ripasheiku_drops_and_lies_open`: the drop is telegraphed, lands, and leaves her open.
- `test_ripasheiku_defeat_gives_the_lantern_key`: beating her gives the key and Mana Dew and unseals the doors.

The chapel is in `MATTOCK_ROOMS` and passes reachability.

## Screenshots

`/mnt/project-files/pass-37/`:

- the chapel as she pounces through the fog;
- her stalking on the floor, with her lanterns lit;
- Lantern Landing with its new east door.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 84 | Unchanged. |
| World and level design | 15 | 87 | The chapel ends the first Mist stretch. |
| Art cohesion | 15 | 81 | A 2x code-drawn spider that reads in the fog. |
| Bosses | 10 | 82 | Third boss: a light-reading fight with three distinct phases. |
| Systems | 10 | 82 | Unchanged. |
| Audio | 5 | 80 | Unchanged. |
| Stability and performance | 5 | 78 | Unchanged. |
| Faithfulness | 5 | 81 | Ripasheiku and the Lantern Key, as the bible plans. |

Weighted score: 83.75 (up from 83.30).

## Lowest categories and next pass

1. **Stability (78)**: soak the fog shader and the chapel fight for frame time.
2. **Faithfulness and Art (81)**: a bitmap pixel font, and an HD Autosprite sheet for Ripasheiku.
3. **Bosses (82)**: Zorugeriru, behind the Lantern Key.
