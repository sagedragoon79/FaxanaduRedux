# Pass 43: Wing Boots

The plan for this pass was Zorugeriru. Bible 8.4 builds his second phase on Deluge, which floods the basins to float
platforms up to his hidden head. Deluge isn't in the world yet, and neither are the Wing Boots, the Mist's first
ability (bible 4.2: Wing Boots, then Deluge, then Zorugeriru). So this pass places the Wing Boots, the next step on the
critical path, and leaves the boss until Deluge exists.

## What changed

- **Feather Hollow** (mist 27,-8), reached through a new west door at floor level in the Victim Causeway. It is a
  drowned roost where the elves' messengers left their boots.
  - The **Wing Boots** (legend `X`) sit on a reliquary perch four rows up, reachable with a plain jump.
  - From a step beside the perch, a **Life Fruit** waits six rows higher on a boardwalk that only a second jump
    reaches. It is the first thing to try the boots on.
  - The room also has a chest (180 g), a Bog Myconid, a Lantern Ghost and a sign.
- **Picking up the boots** grants the `boots` ability, which turns on the double jump (it was already in the
  controller), and shows the banner "Wing Boots: Jump again in mid-air. A pogo or a wall gives it back." Like the
  glove, it is saved.
- **Ability pickups glow in the fog.** The glove and the boots join the fog's `light` group (44 px), so the Mist can't
  hide them.
- **The boots pickup is drawn at 2x:** a sky-blue messenger's boot with a gold cuff and a fluttering white wing at the
  heel.
- **`reach.gd` models the double jump.** With `boots`, jumps use `BOOT_JUMP` (rise up to 6 rows, wider at every
  height), a little under the real 120 px of rise from `jump_height` plus `double_jump_height`.
- Bible 4.1 (A3) names Feather Hollow, and bible 4.4 (the Ripasheiku row) adds it. `levels/README.md` has the `X`
  legend row.

## Tests

- `test_reachability.gd`: a new test, `test_wing_boots_reach_the_high_perch`, checks four things:
  - the boots can be reached without them;
  - the perch fruit (`BOOT_SECRETS`) can't be reached without them;
  - with them, every pickup in the game is reachable;
  - with them, nothing soft-locks.

  `PICKUPS` now counts `X`. `mist/feather_hollow` is in `MATTOCK_ROOMS`.
- `test_world.gd`: a new test, `test_wing_boots_grant_the_double_jump`, checks three things:
  - a new game starts without the boots;
  - taking them sets the ability on the player and in the save;
  - they don't come back.

## Screenshots

`/mnt/project-files/pass-43/`: Feather Hollow, and a close-up of the boots glowing on their perch.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 89 | The double jump is now earned in the world, with a perch built to try it on. |
| Combat and enemies | 15 | 86 | Unchanged. |
| World and level design | 15 | 89 | The Victim road continues. The Mist has 7 rooms. |
| Art cohesion | 15 | 84 | Unchanged. |
| Bosses | 10 | 84 | Unchanged. |
| Systems | 10 | 85 | The Mist's first ability gate, checked by reachability with and without it. |
| Audio | 5 | 84 | Unchanged. |
| Stability and performance | 5 | 83 | Unchanged. |
| Faithfulness | 5 | 85 | Unchanged. |

Weighted score: 86.15 (up from 85.70).

## Lowest categories and next pass

Stability (83) is the lowest. Art, Bosses and Audio are at 84. Next: the Mascon side and Deluge, the second Mist
ability, which Zorugeriru's fight needs. Its gates are fire seals and dry basins (bible 4.5). After that comes
Zorugeriru.
