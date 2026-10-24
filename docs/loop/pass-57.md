# Pass 57: Daybreak town, and the Fire spell

The world goes past the Broken Shrine. A stride crossing leads to the bell town of Daybreak (bible 3.2 and 10.2), and
its scribe sells the first supporting spell, Fire, with bramble walls for it to burn.

## What changed

- **Fallen Bridge** (`daybreak/fallen_bridge`, 52,-11, 60x23), off the Broken Shrine's new east door:
  - The great bridge is broken into four floating spans, each gap a stride wide. Hornets ride the wind.
  - A fall lands on the old footing, where a Thunder Beetle walks. The near pier can be climbed back up, and storm
    crystals on the far pier's face stop a climb round the gaps.
- **Daybreak** (`daybreak/daybreak`, 54,-11, 80x23), the bell town:
  - **Guru**.
  - **Calder the Armorer** sells Full Plate (tier 3, 45% less damage, 4,200 g).
  - **Scribe Ysolde** sells the Fire scroll (1,200 g).
  - **Grocer Wenna** sells Elixir, Ointment, Jack keys and a Mana Dew (once).
  - **Bell-Ringer Tamsin**, on the bell-loft gallery, sells the Daybreak chart (700 g).
  - **The Mayor** names Borabohra, and **the old Bellkeeper** points at the bramble-choked bell cellar.
  - All six new townsfolk get sheets from `castgen.py` (existing sheets unchanged).
  - Music `daybreak_town`: G mixolydian at 92, a carillon ringing each chord down over warm pads and a walking bass.
    Loudness is level with `conflate`.
- **Fire** (`scripts/combat/fireball.gd`, bible 4.1):
  - Costs 20 MP. The ball is thrown forward and up and falls under gravity, landing about seven tiles ahead.
  - It bursts on a wall, a floor or a foe: every foe within 20 px takes 18, and every bramble in reach catches.
  - It lights the fog as it flies, with ember sparks on the burst and new `fire_burst.wav`.
- **Next Spell**:
  - A new action, `spell_next` (G or O, or the right stick click), cycles the spells you own in `Spells.ORDER`. It is
    rebindable in Controls.
  - The magic bar's gem takes the equipped spell's color. `GameState.data.spell` saves the choice.
  - Shops gain a `spell` item kind: buying a scroll teaches the spell and equips it if you had none.
- **Bramble walls** (`scripts/world/bramble_wall.gd`, legend `w`, bible 4.5):
  - Crossed thorn-vines that block like stone and shrug off blades.
  - Fire sets a tile alight, the flames creep to touching tiles, and the knot burns to ash in about a second.
  - Each tile is remembered by room and tile. `reach.gd` treats `w` as solid until the "fire" ability.
- **New sounds**: `fire_burst` and `crackle`, appended to `sfxgen.py`, so every existing wav is byte-identical.
- **Screenshots**: `--cast=SPELL` learns a spell and casts it on frame 10.
- **Bible**:
  - 3.2: Daybreak town as built.
  - 4.1: Fire as built.
  - 4.5: bramble walls.
  - 5.3: the Next Spell button. The bible said "cycle with shoulder buttons", but Dash and Block already hold the
    shoulders.
  - 10.2: Daybreak's stock. The Magic Shield and Tilte are deferred until their mechanics exist.
  - The README legend gains `w`.

## Tests

- `test_combat.gd`:
  - `test_fire_arcs_bursts_and_scorches_foes_in_reach`: MP cost; the ball rises, then bursts on a dummy seven tiles
    away and is gone.
  - `test_next_spell_cycles_only_through_spells_you_own`.
- `test_world.gd`: `test_fire_burns_the_bramble_for_good`:
  - Four bramble tiles in the bell cellar shrug off a slash.
  - One fireball burns them all to ash.
  - Re-entering the room finds them still burnt.
- `test_economy.gd`: `test_daybreak_sells_plate_charts_and_the_fire_scroll`:
  - Every townsperson and their sheet is there.
  - Fire costs 1,200 g, is taught and equipped, and then shows as owned.
  - Full Plate takes off 45%, and the chart is sold.
  - The equipped spell survives a capture and apply.
- `test_reachability.gd`:
  - The two rooms are added to `MATTOCK_ROOMS` and `STRIDE_ROOMS`.
  - New `FIRE_SECRETS`.
  - `test_fire_burns_the_bramble_to_the_bell_cellar`: the Stride reaches the town and the gallery. The cellar's
    Potion Shard is shut until Fire, then reachable, with no soft-locks.
- `test_boss.gd`: the music list includes `daybreak_town`.
- The Daybreak soak and the room checks pick up the new rooms on their own.

## Screenshots

`/mnt/project-files/pass-57/`:
- `daybreak_town.png`: the street with the armorer, scribe and mayor.
- `fallen_bridge.png`: the spans with hornets and the beetle below.
- `fireball.png`: a fireball in flight, with the HUD gem orange.
- `bramble_burning.png`: the cellar's bramble alight.
- `bell_cellar.png`: the bramble before it burns.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 88.5 | A second spell, with an arc that plays differently from Deluge. |
| World and level design | 15 | 92.25 | A stride crossing and a town, with a Fire secret. |
| Art cohesion | 15 | 84.25 | Unchanged (on hold). |
| Bosses | 10 | 88.5 | Unchanged. |
| Systems | 10 | 89 | Spell scrolls, spell cycling, tier 3 armor, Daybreak shops. |
| Audio | 5 | 88.5 | A town theme and two effects. |
| Stability and performance | 5 | 86.75 | Unchanged. |
| Faithfulness | 5 | 88.5 | Daybreak's town and the Fire scroll where the original sold them. |

Weighted score: 88.69 (up from 88.51).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (86.75). Then Combat (88.5) and Bosses (88.5). Next is the Spires above
Daybreak:
- the Thunder spell and its dead conduits (bible 4.1, A6);
- a Storm Harpy;
- after that, Borabohra.

The Magic Shield's reflect and the ObjectDB leaks are queued as smaller items.
