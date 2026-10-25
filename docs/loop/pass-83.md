# Pass 83: The Heart of the Meteor

This pass builds phase 3 of the Evil One, The Core (bible 8.9). This is the last fight of the game.

## What changed

- **EvilHeart** (`scripts/bosses/evil_heart.gd`, boss id `evil_one`): the meteor's heart, a crystal eye-flower that hangs far above the floor. It has 300 HP and `PHASES [0.66, 0.33]`.
  - It drifts after you and attacks every 2.0, 1.7 or 1.4 s, depending on phase:
    - **Beam**: a `CoreBeam` with a 0.6 s tell, or 0.45 s in phase 3.
    - **Seeds**: three Meteor Seeds around you.
    - **Wave** (from phase 2): crystal gathers under it for its tell, then spikes run along the floor both ways.
  - It can only be hurt while bound, and only by a swing of the Dragon Slayer. Other blades and magic glance off.
  - Each third of its life frees a spring's light. The light heals a quarter of your health and makes the roots come quicker.
  - Phase 3: it bursts as the root lets go (56 px, 14 damage, unparryable), and flashes for 0.5 s first.
  - The Hour Glass holds it and its roots.
- **TreeRoot** (`scripts/bosses/tree_root.gd`): the Tree's ally attack, every 7, 6 or 5 s depending on phase.
  - The floor glows green for 0.8 s, then a root lashes up, binds the heart and drags it to the floor for 2.4 s.
  - The heart draws the roots wound over it while it is held.
- **HeartLight** (`scripts/bosses/heart_light.gd`): three sockets in the vault. A freed light fills its socket and pours a shaft of blue light down.
- **BossArena**: the `evil_one` entry, titled "The Heart of the Meteor Dies", with 1 skill point and the `evil_one` music.
- **Rooms**:
  - `zenis/heart` (70,-13, 60x23): a long chamber with two low ledges and a sign.
  - The Veins gain a ledge under the vault and door 2 on the east wall.
- **Fix**: `test_the_dragon_slayer_cuts_the_flesh_of_the_heart` read the seal after walking through it. Since pass 81 the walk can carry the player out of the room, which logged a script error. The test now notes the seal first.
- **Docs**: bible 8.9 has an as-built note. It records one deviation: a spring returns per third of the heart's life, not per strike.

## Tests

- `test_boss.gd`:
  - `test_the_heart_wakes_above_any_blade`
  - `test_the_trees_roots_bind_the_heart_after_a_tell`
  - `test_only_the_dragon_slayer_cuts_the_bound_heart`
  - `test_each_third_cut_frees_a_springs_light`
  - `test_the_hearts_attacks_are_telegraphed`
  - `test_the_heart_bursts_as_the_root_lets_go_at_the_end`
  - `test_the_hour_glass_holds_the_heart_and_its_roots`
  - `test_the_heart_of_the_meteor_dies_for_good`
- `test_soak.gd`: `test_evil_heart_fight_soak_stays_lean` (2400 frames through all three phases; 0.49 ms a frame).
- `test_reachability.gd`: the Heart is in the mattock and thunder room lists.

## Screenshots

`/mnt/project-files/pass-83/`:
- `heart_float.png`: the heart hangs high and sows seeds around you.
- `heart_bound.png`: a root holds it down.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 91 | Unchanged. |
| Combat and enemies | 15 | 91 | Unchanged. |
| World and level design | 15 | 96.25 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged. |
| Bosses | 10 | 95.5 | The final boss is whole, and the Tree's roots give it a rhythm. |
| Systems | 10 | 91 | Unchanged. |
| Audio | 5 | 91 | Unchanged. |
| Stability and performance | 5 | 89 | One more boss soak. |
| Faithfulness | 5 | 92.5 | The Dragon Slayer is finally the only answer to the Evil One. |

Weighted score: 91.28 (up from 91.18; 91.275 unrounded).

## Next

The ending and credits (bible 8.9, Reward): the heart dies, and the credits climb the Tree from Eolis to the crown.
