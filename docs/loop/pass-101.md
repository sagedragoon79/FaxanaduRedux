# Pass 101: Feather Fall, and the air numbers pinned

Movement (93.25) was the lowest category apart from Art. This pass builds Feather Fall, the glide promised in the Wanderer branch, and checks the remaining air and dash numbers in bible 6 in scripted runs.

## Feather Fall

Feather Fall is a Wanderer skill [2], after Second Stride. It needs the Wing Boots. Bible 6.10 now specifies it; the numbers are in `movement_tuning.gd` (Feather Fall group).

- **How it works:** once the double jump is spent, holding Jump while falling eases the fall to 60 px/s.
  - A fast fall brakes down to that speed at 1,500 px/s².
  - A slow one (just past the apex) falls into it at the normal fall gravity.
  - The glide stands in for gravity while it lasts.
- **Air control is unchanged**, so a glide drifts about 2.75 px across for each 1 px down.
- **Leaving it:** release Jump, or hold Down to drop at full speed. Landing, a wall, a dash, water, wind or an updraft also end it. Each frame the glide has to be renewed, so no other air state can leave it stuck on.
- **Feel:** a wide squash and a soft whoosh (new `glide` sound) as it opens. The cloak-spread apex pose is held, and a feather is shed every 0.14 s.
- **No new routes:** it refreshes no air move, so it never reaches anything a double jump and a dash couldn't. It is comfort and reach for players who buy it.
- `--glide=FRAME` (`game.gd`) glides for screenshots.
- The tree now costs 38 points against the game's 29.

Screenshot: `/mnt/project-files/pass-101/glide.png`. It shows the glide over the gym's 10-tile gap at 165 px/s across and 60 px/s down, in the apex pose, with feathers trailing.

## Air and dash audit (bible 6.2 and 6.5)

| Item | Bible | Result |
| --- | --- | --- |
| Air acceleration | 1,400 px/s² | Matches: 116.7 px/s after 5 frames. New test. |
| Air deceleration | 900 px/s² | Matches. New test. |
| Dash distance | 380 px/s for 0.15 s | Matches (existing test). |
| Dash holds height | no gravity | Matches (existing test). |
| Dash invulnerability | first 0.10 s only | Matches: invulnerable at the start, not after 0.10 s. New test. |
| Ground dash cooldown | 0.25 s | Matches. New test. |

Nothing was off. The new tests pin these numbers so a later change can't drift from the bible unnoticed.

## Tests

`test_abilities.gd`:
- `test_feather_fall_glides_after_the_double_jump`: no glide with the double jump in hand, then glide speed, 30 px in half a second, full air control, Down drops out, Jump held again catches the air, and release falls.
- `test_feather_fall_needs_the_skill_and_brakes_a_fast_fall`: no glide without the skill, and a 520 px/s fall reaches glide speed in about 18 frames.
- `test_air_control_matches_the_bible`
- `test_dash_invulnerability_and_cooldown`

The skill-tree tests now include Feather Fall in the Wanderer chain.

Full suite: 1931 checks, all passing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 94 | A new, fully specified air move with its own feel, and the air numbers pinned by tests. |
| Combat and enemies | 15 | 94 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.25 | Unchanged. |
| Systems | 10 | 94.75 | One more meaningful node in the tree. |
| Audio | 5 | 93.75 | Unchanged (one new sound, in range). |
| Stability and performance | 5 | 94 | Unchanged. |
| Faithfulness | 5 | 96.25 | The Wanderer branch's signature move from the bible is in. |

Weighted score: 93.66 (up from 93.48; 93.6625 unrounded).

## Next

Combat (94), Stability (94) and Audio (93.75) are now the lowest apart from Art. Pass 102 takes Audio: a sound audit of every enemy and boss attack (wind-up, strike and death sounds), filling in any action without its own sound.
