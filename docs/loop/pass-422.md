# Pass 422: the fight, heard through the buttons

## Category

Audio (last pass 414).

## Audit

Through the real controller the suite hears the menus (398), rests and pins (406) and the ready chimes (414). Pass 418 pressed Block for real against the Rot Dwarf, but it read only the blow's outcome. The four sounds that tell those outcomes apart (the parry's ring, the hurt cry, the guard's thud and the guard break's crack) were only heard with a scripted guard, and nothing checked that a parry rings alone. The mix is clean (`python3 tools/audio/levels.py --check`: 166 effects at a median of -18.5 dB, 34 music files at -14.7 dB, 14 ambience files at -21.4 dB).

## Fix

- `_real_block_against_the_dwarf` (test_combat.gd) now sets MP as Block goes down, takes the MP to start with, and returns the fight's sounds from the press on.
- `test_the_fight_is_heard_through_the_buttons`, all with Block pressed for real:
  - Seen at the parry window's last step: `parry` once, nothing else.
  - A step too soon: `hurt` alone.
  - Held from long before: `guard`, then the halved blow's `hurt`.
  - Held with less MP than the guard costs: `guard_break`, then `hurt`, and the whole 20-point blow lands.
- Bible 13.3 gains "The fight, heard through the buttons (pass 422)".

Mutation: a parry that also plays the guard's thud fails only the new test; every other parry test still passes.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Score unchanged. Each guard outcome is heard alone through the real controller. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted: 96.8625.

## Next

Pass 423: Stability.
