# Pass 190: gear that sounds like itself

Audio's last pass (181) was the oldest apart from Art, so pass 190 takes Audio. I audited the sound (bible 13, Audio) against the newest content (passes 181 to 189).

| Check | Finding | Verdict |
| --- | --- | --- |
| **The Rune Dagger's strike (pass 184)** | The throw and the return each have a sound, and so does a wall. A dagger that struck a foe played nothing: `Enemy.take_hit` makes no sound, because the blade plays `hit` itself, and the dagger never did. So the moment the tool pays off was silent. | **built: `dagger_hit`** |
| **The Dwarvish Broad Sword (pass 186)** | It is two-handed and swings 30% slower, but it cut with the same `slash` and `heavy` as the Short Sword, so its weight was seen and not heard. | **built: `broad_slash`, `broad_heavy`** |
| **The Equipment page (passes 186, 189)** | Every change played `cloth`, the dye's swish, even taking a sword in hand or buckling on plate. | **built: `sheathe`, `gear_on`** |
| The Matriarch (pass 179) | She has her own voice (`matriarch_cackle`, `bog_sink`, `bog_rise`) over her daughters' hex sounds, and the voices test holds her to it. | fine |
| The helmet (pass 185) and the cloak layer (PR #206) | They are drawn layers with no action of their own; putting the helmet on now buckles. | fine |
| The mix | `levels.py --check` passes with the five new sounds. | fine |

## As built

- `tools/audio/sfxgen.py` has five new sounds:
  - `dagger_hit`: a high tick of the point going in over a small dry knock.
  - `broad_slash` and `broad_heavy`: a longer, lower rush of air with weight under it, and a deeper body for the heavy cut.
  - `sheathe`: steel sliding from the sheath, then a seating click.
  - `gear_on`: leather, then a buckle's clink.

  Running the generator also rewrites other sound files, so I restored those with git and kept only the five new ones.
- `RuneDagger` plays `dagger_hit` when it strikes.
- `Player.swing_sound()` picks `broad_slash` or `broad_heavy` while a two-handed blade is held.
- `Menus.equipment_sound(id)` gives the Equipment page `sheathe` for a blade, `cloth` for a dye and `gear_on` for anything else. `Menus.choose_equipment` plays it.
- Bible 13 (Audio) has a new "Gear that sounds like itself" entry.

## Tests

- `test_combat.gd`, `test_the_dagger_the_broad_sword_and_the_equipment_page_have_voices` (new), through `Sfx.recent`:
  - a thrown dagger that lands plays `dagger_hit`;
  - the Short Sword cuts with `slash`, the Broad Sword with `broad_slash` (and `broad_heavy`);
  - the five files exist;
  - the Equipment page's sound for a blade, armor, a shield, a helmet and a dye, and choosing a blade plays `sheathe`.

Full suite: 3526 of 3526 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged: the dagger's strike is no longer silent, and the heavy blade and the gear are heard as what they are. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 191 takes Stability (last pass 182, now the oldest).
