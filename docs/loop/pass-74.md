# Pass 74: Shadow Eura, the mirror

The first phase of the shadow before the gate of Zenis (bible 8.8).

## What changed

- **Shadow Eura** (`scripts/bosses/shadow_eura.gd`, boss id `shadow_eura`), phase 1:
  - Mirroring: it takes the place, facing and sprite pose you had `DELAY` (0.6 s) ago, mirrored across the middle of the
    hall. Walk left and it walks right, and when you jump, it jumps.
  - Echoes: every swing you make (side, up or down) comes back from its side `DELAY` later. Its blade glints for
    `SWING_TELL` (0.4 s) first. The echo uses your own swing's hitbox and deals 14 damage, and it can be parried.
  - You can only reach each other where you meet at the mirror line, so every blow you land is answered. Step out of
    the echo or parry it. A parried echo staggers it for 1.2 s, out of the mirror, and then it blinks back.
  - Stillness is punished: hold still for 2.2 s and it sinks into the floor (untouchable), rises 30 px behind you with
    its blade raised (`RISE_TELL` 0.45 s), and cuts.
  - Drawn in code: your own sprite frame as a flat silhouette of shadow with a violet rim, pale eyes and a crystal
    blade. A faint seam of light marks the mirror line.
  - 150 HP and `PHASES` empty for now. Phases 2 and 3 come later.
- **The gate hall** is now a mirrored arena: it has `boss: shadow_eura`, a landing at each end, the shrine on the
  west landing and the gate on the east landing. BossArena gives a skill point ("The Mirror Breaks"). Once it is
  beaten, the gate says nothing watches any more. It still does not open, because Zenis is not built.
- **Docs**: bible 8.8 has an as-built note.

## Tests

- `test_boss.gd`:
  - `test_shadow_eura_waits_before_the_gate_as_your_reflection`: the mirror line and the mirrored, delayed position.
  - `test_shadow_eura_echoes_your_swing_and_a_parry_breaks_it`: the tells are at least `MIN_TELEGRAPH`, the echo
    lands, and a parry staggers it.
  - `test_shadow_eura_comes_through_the_mirror_if_you_hold_still`.
  - `test_beating_shadow_eura_breaks_the_mirror`.
- `test_rooms.gd`: the gate's message after the shadow is beaten.
- `test_soak.gd`: `test_shadow_eura_fight_soak_stays_lean` (0.49 ms a frame; every state seen; its history stays
  short).

## Screenshots

`/mnt/project-files/pass-74/mirror.png`

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90.25 | Unchanged. |
| Combat and enemies | 15 | 90.25 | Parrying your own echo is a new read on the parry. |
| World and level design | 15 | 94.5 | Unchanged. |
| Art cohesion | 15 | 84.5 | Unchanged. |
| Bosses | 10 | 91.75 | A boss built from the player, unlike any other. |
| Systems | 10 | 90.5 | Unchanged. |
| Audio | 5 | 89.5 | Unchanged; it uses the generic boss track for now. |
| Stability and performance | 5 | 89 | One more boss soak. |
| Faithfulness | 5 | 90.25 | Unchanged. |

Weighted score: 90.10 (up from 89.98).

## Lowest categories and next pass

Leaving Art aside, the lowest is Stability (89). Next: Shadow Eura phase 2 (it acts on its own, using your strongest
skill tree branch) and its own music.
