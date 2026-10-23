# Pass 39: Ripasheiku's sound

Audio was lowest at 80. Pass 37's Lantern Widow fought to the shared boss theme, and she borrowed other sounds: a
`whir` for her web, a `hit` for the catch, and a stone `break` for her lanterns. This pass gives her her own voice.

## What changed

- **Her theme** (`track_ripasheiku` in `tools/audio/musicgen.py`, `assets/music/ripasheiku.ogg`, about 26 s, looping).
  It is the Mist's drowned waltz turned hunter: B phrygian in a fast 3/4 at 168 bpm.
  - A creeping bass climbs a half step every bar.
  - Skittering ticks play like many legs on stone, panned about the room.
  - Lantern bells toll the chord.
  - A heartbeat kick lands on the downbeat.
  - A bell lead enters at bar 5.
  - Its loudness (-17 dB mean, -1.4 dB peak) sits with the other boss themes.
  - `BossArena.BOSSES.ripasheiku.music` picks it.
- **Five new sounds** (`tools/audio/sfxgen.py`), appended at the end so every existing wav stays byte-identical
  (checked with md5):
  - `web_shoot`: an elastic zip that rises and snaps tight, for the strand she shoots.
  - `web_catch`: a wet slap with a wobbling low twang, for when it catches you.
  - `reel`: a ratchet of ticks over a rising strain, lasting the 0.9 s she reels you in.
  - `skitter`: a patter of dry clicks, for her climb to the vault and the shiver before she drops.
  - `lantern_break`: thin glass and a bright tinkle, for a soul-lantern shattering.
- Bible 13 (music list) now describes boss themes as a shared theme plus signature themes per boss.

## Tests

- `test_music_follows_rooms_and_bosses` checks that `ripasheiku` is a looping track.
- `test_sunken_chapel_wakes_the_lantern_widow` checks that the fight plays her theme.
- New `test_every_sound_the_code_plays_exists` (test_rooms):
  - It scans every script for `Sfx.play("…")` and `Music.play("…")`, and reads every boss's music, then checks that
    each file exists.
  - A typo would otherwise play silence, not fail.
  - It found no missing names. The only hit was `"step_" + surface`, a prefix completed at runtime, which it now skips.

## Screenshots

`/mnt/project-files/pass-39/`: waveforms of the five new sounds, and a spectrogram of the theme.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 84 | Unchanged. |
| World and level design | 15 | 87 | Unchanged. |
| Art cohesion | 15 | 82 | Unchanged. |
| Bosses | 10 | 84 | Her attacks now read by ear: the zip, the catch, the patter before a drop. |
| Systems | 10 | 82 | Unchanged. |
| Audio | 5 | 84 | A signature boss theme and five purpose-made sounds; a guard against missing sounds. |
| Stability and performance | 5 | 83 | The sound-name scan. |
| Faithfulness | 5 | 81 | Unchanged. |

Weighted score: 84.55 (up from 84.20).

## Lowest categories and next pass

1. **Faithfulness (81)**: a bitmap pixel font, in the NES spirit, for menus, dialogue and the HUD.
2. **Systems and Art (82)**: the Lantern Key gate and the road on toward the Spring of Mist.
3. **Audio (84)**: a "restored" variant of each zone track for when its spring returns (bible 13).
