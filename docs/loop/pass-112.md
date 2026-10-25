# Pass 112: foe voices

Audio (95.5) was the lowest category apart from Art. Pass 102 gave every attack a sound, but it did that with shared cues: three rising tells (`tell_blade`, `tell_heavy`, `tell_charge`) and a few strikes (`whoosh`, `slash`, `heavy`). The foes built since then took whatever cue was nearest, so by ear they sounded like older foes, or like bosses.

## Audit

The audit counted which foe and boss scripts play each attack sound.

| Foe | Tell / strike before | Also played by |
| --- | --- | --- |
| Bark Knight | `tell_charge` / `whoosh` / `thorn` (rooting) / `crumble` (bark chip) | Ripasheiku and Shadow Eura (`tell_charge`); Hornet and Lantern Ghost (`whoosh`); thorn bulbs and crystal shards (`thorn`); eight scripts (`crumble`) |
| Drowned Dwarf | `tell_heavy` / `heavy` | Zoradohna and Rokusutahn (`tell_heavy`); the Minecart Rider, Shadow Eura and arena seals (`heavy`) |
| Leaf Mantis | `skitter` / `slash` | Ripasheiku (`skitter`); the Clockwork Hound, Gear Bat, Shadow Eura and King Grieve (`slash`) |

The older foes keep the shared cues. That is what the cues are for: a family of sounds that teaches "blade", "heavy" and "shot". The other foes already had voices of their own: the eel lunge, buzz, wail, screech, zap and so on.

## New sounds

All eight are made in `tools/audio/sfxgen.py` and are deterministic. Each tell still rises toward its strike, as pass 102 asked, but in the foe's own material.

| Sound | Foe, moment | Recipe |
| --- | --- | --- |
| `bark_creak` | Bark Knight, brace (the tell) | a saw creak climbing 70 to 150 Hz, gated by a stick-slip pulse that speeds up, with wood grain noise |
| `lance_thrust` | Bark Knight, thrust | a woody rush ending on a triangle-wave thock |
| `root_grip` | Bark Knight, rooting | a low noise crunch falling in pitch, with sparse splinter clicks |
| `bark_chip` | Bark Knight, a plate knocked off | a dry high crack over a hollow knock; louder on the last plate |
| `anchor_heave` | Drowned Dwarf, heave (the tell) | a sodden saw groan swelling up, nine rising bubble blips, and water pouring |
| `anchor_slam` | Drowned Dwarf, slam | a deep square thud falling to 40 Hz and a wet noise slap |
| `mantis_unfold` | Leaf Mantis, unfold (the tell) | a leaf rustle opening up, then a gated chitter |
| `scythe` | Leaf Mantis, lunge | two thin high cuts 60 ms apart |

**Mix:**
- `levels.py --check` passes for all 90 sound effects.
- The new tells sit at an RMS of -16 to -19 dB, against a median of -17.7.
- `anchor_slam` is the loudest at -11.7 RMS, close to `tell_heavy`. It is the heaviest blow a common foe lands.
- Nothing clips.

`sfxgen.py` again rewrote nine unrelated files with tiny byte diffs, so those were checked out.

## Tests

- `test_the_newer_foes_have_voices_of_their_own` scans the enemy, boss, world and player scripts. Each of the eight sounds must exist and must be played by its foe alone (16 checks).
- `test_every_attack_tell_and_strike_has_a_sound` still passes.
- The behaviour tests for the three foes are unchanged and pass.

## Bible

The audio section has a new "Foe voices (pass 112)" entry. It sets the rule (shared tells for the older foes and bosses, own voices for later foes) and describes each new sound.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96 | Unchanged. |
| Combat and enemies | 15 | 96 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 95.75 | Unchanged. |
| Audio | 5 | 96 | The three newest foes can be told apart by ear, a test guards it, and the mix check still passes. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Full suite: 2166 checks, all passing.

Weighted score: 94.725 (up from 94.7).

## Next

Systems (95.75) is now the lowest category apart from Art. Three systems the bible plans are still unbuilt: the boss rush, the Guru Trials and cloak dyes. Pass 113 builds the one the bible gives the most weight.
