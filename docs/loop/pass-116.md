# Pass 116: the mantra-space's own sound

Audio (96) was the lowest category apart from Art. I audited the audio against the bible's audio section and the newer systems:

| Thing | Before | Verdict |
| --- | --- | --- |
| Zone music and ambience | every zone has a theme and a bed, and the Tower's parts have three beds | fine |
| Boss music | every boss has its theme, with phase-break stings (pass 104) | fine |
| Seed Bomber (pass 114) | four sounds of its own | fine |
| Slopes (pass 115) | footsteps read the zone's surface, as on flat ground | fine |
| **Guru Trials (pass 113)** | the rooms named `music: eolis` and `ambience: heights`. Starting a trial and ringing its bell both played `save`, the shrine chime. A new best sounded like any other clear. | **the gap** |
| Mix | `levels.py --check` passes | fine |

The Trials are a whole zone and a system, and they borrowed Eolis' town theme, the Tower rafters' wind and the save chime. In the mantra-space you heard a town and a tower. The bell at the end of a course, the moment the whole trial builds to, sounded the same as saving.

## As built

**Music** `trials` (`musicgen.py track_trials`):
- D lydian at 92, floating and grey.
- A low drone that never changes chord, and a dry tick on every eighth like the trial's clock.
- A soft pulse on one and three to run to.
- A bell chanting a short four-bar mantra above it, the same each time round.

**Ambience** `amb_trials`: a hollow void hum that breathes, thin air moving across nothing, and far chimes of the mantra rings now and then, left and right.

The trial rooms no longer name their music, so the zone `trials` picks both.

**Sounds** (`sfxgen.py`):

| Sound | When | Recipe |
| --- | --- | --- |
| `trial_begin` | the mantra carries you in (`Menus.start_trial`) | a sine shimmer rising a fifth, with a breath of air |
| `trial_bell` | the bell is touched (`TrialGoal.ring`) | a struck bronze bell: seven inharmonic partials (0.5 to 4.07) decaying at different rates, with a short strike |
| `trial_record` | a clear that beats your best | three bright rising notes, the last held |

**Mix:** `levels.py --check` passes (97 sound effects, 26 music tracks, 12 beds).

| Sound | RMS (dB) | For comparison |
| --- | --- | --- |
| `trials` | -17.2 | music median -15.1 |
| `amb_trials` | -22.6 | ambience median -21.1 |
| `trial_begin` | -19.3 | sfx median -17.7 |
| `trial_bell` | -20.6 | sfx median -17.7 |
| `trial_record` | -16.3 | sfx median -17.7 |

`trial_record` was softened from -13.9 dB to -16.3 dB.

I rendered only the two new tracks (`musicgen.py trials amb_trials`). The nine unrelated sound effects that `sfxgen.py` rewrote were checked out.

**For tests:** `Sfx.recent` keeps the last 32 sounds asked for, so a test can hear a moment.

## Tests

- `test_the_guru_trials_have_a_sound_of_their_own` (in `test_systems.gd`):
  - both tracks loop;
  - the three sound files exist;
  - in both built trials, starting plays `trial_begin` and the zone plays `trials` over `amb_trials`;
  - the bell plays `trial_bell` and not `save`;
  - a first clear has no record sting, and a faster clear plays `trial_record`.
- The existing trial tests pass unchanged.

## Bible

- Section 3: the Guru Trials paragraph describes the sound.
- Audio: the ambience entry gains the mantra-space.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96.5 | Unchanged. |
| Combat and enemies | 15 | 96.5 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 96.5 | Unchanged. |
| Audio | 5 | 96.5 | The last zone that borrowed its sound has its own theme, bed and moments. A trial's bell no longer sounds like saving. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Full suite: 2266 checks, all passing.

Weighted score: 95.0 (up from 94.975). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (96.25) is now the lowest category apart from Art. Pass 117 takes Faithfulness.
