# Pass 102: every attack is heard

Audio (93.75) was the lowest category apart from Art. This pass audits every enemy and boss attack for a wind-up sound, a strike sound and a death sound, and fills the gaps.

## The audit

I scanned the 29 enemy scripts and 35 boss scripts (bosses, their parts and their projectiles) for each attack state: where it is entered, and whether a sound plays there or while it runs.

- **Deaths:** every foe calls `Enemy.die()`, which plays `enemy_die`. All 13 bosses play a sound as they start dying. No gaps.
- **Telegraphs:** 30 telegraph states. 10 started in silence, so the warning was only visible:
  - enemies: Rot Dwarf windup, Monodron windup, Minecart Rider rev (its brake squeal waited a frame);
  - bosses: Drowned Warden slam_tell, Evil Avatar cleave_tell (the second swing), Ripasheiku web_tell, Zoradohna dive_tell, Rokusutahn lunge_tell, dangle_tell and plunge_tell.
  - Borabohra's gale_tell screech already played on the same frame; it moved up next to the state change so the test can see it.
- **Strikes:** 68 attack states. 6 made no sound: Hornet swoop, Lantern Ghost lunge, Rokusutahn dangle_down, and Shadow Eura's split, shatter and blink.

## New sounds

There are four new sounds in `sfxgen.py`. Each telegraph cue rises in pitch, so it reads as "about to happen":

| Sound | What it is | Used by |
| --- | --- | --- |
| `tell_blade` | a thin metal scrape climbing in pitch | Rot Dwarf windup, Evil Avatar's second cleave |
| `tell_heavy` | a low groan swelling up from the floor | Warden slam, Zoradohna dive, Rokusutahn dangle and plunge |
| `tell_charge` | a wobbling hum rising to a whine | Ripasheiku's web shot, Shadow Eura's split |
| `whoosh` | a body cutting the air | Hornet swoop, Lantern Ghost lunge, Rokusutahn's dangle, Shadow Eura's blink |

The other gaps use existing sounds:
- Monodron's windup uses a quiet `swell`, like the other small foes.
- The Minecart Rider squeals its brake on the first frame of the rev.
- Rokusutahn's wall lunge starts with a `crumble` where the wall cracks.
- Shadow Eura's shatter plays `break` as the glass bursts.

The new sounds sit inside the mix: their loudness is between -18.8 and -12.9 dB against a -17.7 dB median, and `levels.py --check` passes. The script's rewrite of nine unrelated wavs was reverted.

## Tests

- `test_enemies.gd`: `test_every_attack_tell_and_strike_has_a_sound`. It scans the enemy and boss scripts.
  - Entering a telegraph state (windup, `*_tell`, wind, coil, rev, unfold, gather) must play a sound within three lines.
  - Any other attack state must play one where it starts, through a helper that does, or while it runs.
  - Calm states (walking, recovering, intros, retreats) are exempt.
  - Checked against a mutation: removing the Rot Dwarf's cue and the Hornet's whoosh makes the test fail and name both.
- `test_every_sound_the_code_plays_exists` now also checks names passed to `_sound(...)` helpers.

Full suite: 1933 checks, all passing.

## Bible

- Section 7: a telegraph now has a pose, a flash *and a sound*.
- Section 13.3 Audio: a new bullet describes the attack-sound vocabulary and the test that keeps it.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 94 | Unchanged. |
| Combat and enemies | 15 | 94.25 | Every telegraph can now be heard as well as seen, which helps with off-screen and busy fights. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.25 | Unchanged. |
| Systems | 10 | 94.75 | Unchanged. |
| Audio | 5 | 95.5 | "Every action has SFX" holds for every attack, and a test keeps it that way. |
| Stability and performance | 5 | 94 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 93.79 (up from 93.66; 93.7875 unrounded).

## Next

Stability (94) and Movement (94) are now the lowest apart from Art. Pass 103 takes Stability: a frame-time audit of the heaviest rooms and boss fights, and any hitch over budget fixed.
