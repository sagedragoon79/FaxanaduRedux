# Pass 278: every guardian's tell is heard as it starts

Category: Audio (last pass 270).

## Audit

I read bible 13.3 against what passes 271 to 277 added, then against the rule from pass 102, which says every attack is heard as well as seen.
- **What passes 271 to 277 added holds.**
  - The Naga's `naga_hiss` and `naga_strike` measure -17.4 and -19.3 dB loudness, near the -18.4 median, and are its own.
  - Its parried bite plays the hero's parry.
  - Its coil tracking a climber is the coil's tell, which is already heard.
  - `levels.py --check` is clean.
- **The gap is in the guardians.** `test_every_attack_tell_and_strike_has_a_sound` reads only states that are entered by name. Most guardians pick a move and enter it as `set_state(pick + "_tell")`, or through a helper (`_open`, `_tell`), and the scan cannot see those. Fighting each guardian in its arena showed 15 tells of 7 guardians that started in silence and were heard only when the blow came:
  - the Foreman's pound;
  - Zoradohna's drill and slam;
  - Pakukame's bite, whip and spit;
  - the Drowned Warden's thrust;
  - King Grieve's chop and sweep;
  - Shadow Eura's cut and heavy;
  - all four of the Evil One's avatar's tells.

  Reading the code found more of the same, untried in that fight: the Foreman's throw, the Warden's undertow, King Grieve's burst, and Shadow Eura's cast and dash.

## Fix

- Each of these tells now plays a cue as it starts, chosen by what is coming:
  - `tell_blade` for a cut, thrust, whip or lunge;
  - `tell_heavy` for a chop, pound, slam, bite or heaved rock;
  - `tell_charge` for a spell, a spit, a drill spinning up or a gathering pull.
- Sounds a guardian already made at the start stay as they were: the Foreman's charge roar, the Warden's wave swell and the brood's rustle.
- The cues are the shared ones, so no new sound file is needed and the mix does not change.
- Test: `test_every_guardian_tell_is_heard_as_it_starts` (`test_boss.gd`).
  - It fights every guardian in its arena for 25 s, and at the 10 s mark pushes it past its phase marks so the later tells come too.
  - It fails on any tell that is entered without a sound in that frame or the two after. The hero's own steps, landings and hurts don't count as that sound.
  - It saw 35 tells across 14 guardians.
  - Mutation check: without the fix it fails, naming exactly the 15 silent tells above.
- Bible 13.3: a new entry under "Attack sounds".
- No screenshot: nothing visual changed.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged score: every guardian tell is now heard as it starts. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 279 takes Stability (last pass 271).
