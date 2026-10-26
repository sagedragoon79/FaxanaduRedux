# Pass 128: the map sounds like parchment

Audio (97, weight 5) was tied with Stability as the lowest category apart from Art. I audited the sound against bible 13.3 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Ladders | `ladder`, a knock and a creak every 8 px climbed (pass 124) | fine |
| Card doors, Sky Gate | `door_locked` and `key_turn` (pass 122) | fine |
| Spire Sentinel | its own grind, raise and slam (pass 123) | fine |
| The dissolve | the kill sound and hit-stop land at once, and the body fades under them. A second sound on every kill would crowd the mix. | fine |
| **The map** | It opened, closed, dropped pins and lifted them with `blip`, the menu cursor's beep, the same sound four ways. It is the screen you open most, and it sounded like a menu, not a map. | **fixed** |

## As built

Four sounds, rendered with `sfxgen.py`:
- `map_open`: parchment unrolling, a crackling rustle that settles with a soft flap.
- `map_close`: the sheet folded in on itself with a dull pat.
- `pin`: a pin pressed in, a tiny tick and a short bright ring.
- `pin_lift`: the ring falling and the tick of the pin coming free.

A full map still fizzles. All four sit near the effects' median loudness (-18 to -21 dB RMS), and `levels.py --check` passes. I checked out the eleven unrelated sounds that `sfxgen.py` rewrote.

## Files

The four sounds are in `/mnt/project-files/pass-128/`, to listen to.

## Tests

`test_map_pins_drop_and_lift_where_you_stand` (`test_economy.gd`) now also checks:
- a pin goes in with `pin` and comes out with `pin_lift`;
- a full map fizzles;
- opening the map plays `map_open` and closing it plays `map_close`.

## Bible

Section 13.3: "The map (pass 128)".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.25 | Unchanged. |
| Combat and enemies | 15 | 97.5 | Unchanged. |
| World and level design | 15 | 97.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | The map has its own parchment sounds instead of the menu beep. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 97.25 | Unchanged. |

Full suite: 2464 checks, all passing, with no script errors in the log.

Weighted score: 95.5625 (up from 95.5375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Stability (97) is the lowest apart from Art. Pass 129 takes Stability.
