# Pass 122: locks that sound like locks

Audio (96.5) was the lowest category apart from Art. I audited the sounds of what passes 113 to 121 added against the bible's audio notes (13.3, Audio).

| Moment | Before | Verdict |
| --- | --- | --- |
| Guru Trials: entering, the bell, a new best | own sounds (pass 116) | fine |
| Marsh Hag: hex, mud hand, fumble | own voice (pass 119) | fine |
| Joker Key, Battle Helmet, card keys bought | the pickup and shop chimes every item uses | fine |
| Slopes and the ground stride | footsteps follow the surface; the stride uses the dash sound | fine |
| Menus | the list menu's move, confirm and fizzle on a refusal | fine |
| **A card door, locked** | `fizzle`, the spell-fail sound. A door you bump read by ear as a spell you failed to cast. | **fixed** |
| **A card door, opening** | `door`, the plain creak every room door plays. Spending a key you saved for, or the one Joker Key, sounded like walking through a room. | **fixed** |

## As built

- **`door_locked`:** the latch rattles in its iron keep, and the door knocks twice against the bolt, dull and heavy. It plays once each time you walk into a door without its key.
- **`key_turn`:** three ratchet clicks of the wards, the bolt's thunk as it draws back, then a small bright chime (E6 with a fifth and an octave above, ringing off).
- Both doors use them: every card door (Jack to Joker) and the Sky Gate (`KeyDoor`).
- Rendered with `sfxgen.py`. `door_locked` sits at -15.7 dB RMS and `key_turn` at -18.9, both inside the effects' spread. `levels.py --check` passes. I checked out the 11 unrelated sound effects that `sfxgen.py` rewrote.

## Sounds

`/mnt/project-files/pass-122/door_locked.wav` and `/mnt/project-files/pass-122/key_turn.wav`. Nothing visual changed, so there are no screenshots.

## Tests

`test_card_doors_take_only_their_own_key` (`test_economy.gd`) now also checks:
- walking into a Queen door with the wrong keys plays `door_locked` once and never `fizzle`;
- the Queen Key opening it plays `key_turn` and not the plain `door` creak;
- both sounds are rendered.

## Bible

- 4.5, Key doors: their sounds.
- 13.3, Audio: a "Locks" note.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97 | Unchanged. |
| Combat and enemies | 15 | 97 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | Unchanged. |
| Audio | 5 | 97 | The last borrowed cue on a reward moment is gone: locks are heard as locks, and a key you spend has its own payoff. |
| Stability and performance | 5 | 97 | Unchanged. |
| Faithfulness | 5 | 96.75 | Unchanged. |

Full suite: 2392 checks, all passing.

Weighted score: 95.3 (up from 95.275). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Faithfulness (96.75) is now the lowest category apart from Art. Pass 123 takes Faithfulness: the Spire Sentinel, the last planned foe of bible 7, or another gap against the original.
