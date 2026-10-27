# Pass 168: the Mantra of Falling

Every category apart from Art was tied at 98.75. Movement weighs the most (20), so pass 168 takes Movement. I audited movement against bible 6 and the newest content (passes 161 to 167).

| Check | Finding | Verdict |
| --- | --- | --- |
| Bible 6 numbers | `movement_tuning.gd` and the movement tests still match bible 6 | fine |
| Frozen footholds (pass 162) | a stilled fall climbs in short hops and is never safe footing; the trials soak turns the glass (pass 166) | fine |
| Zenis remixes (pass 161) | the new foes stand on floors and fly in open air; the Drift Well's wrong gravity is unchanged | fine |
| The farewell walk (pass 167) | drawn on the ending card only; nothing in play changes | fine |
| **The Guru Trials** | Bible 3.1 plans six movement courses. Five were built. The Mantra of Falling was still listed in `Trials.LIST` with an empty description and no room. It was the only planned course left unbuilt, and the only one about controlling a fall instead of rising. | **built** |

## As built

**`levels/trials/falling.room`** (40 x 90) is the Mantra of Falling. It opens with Stillness by the third spring and needs only the Glove. It is a descent in three parts:

1. **The steps:** five three-tile ledges fall away above a spike floor. Each is four or five rows below the last and three or four columns over. You walk off each one and steer to the next.
2. **The well:** a gap in the spike floor drops you into a well with three planks across it. You drop through each plank in turn.
3. **The needle:** walk west into a nine-tile shaft 28 rows deep. Thorn bulbs alternate left and right of center, so only a fall held to the middle column gets through. The bell stands on a slab at the bottom, with spikes on either side.

The trial's other settings:

- `Trials.LIST` gives it a description, a mantra time of 10 s and the dye **Plummet Umber** (`a8703a`).
- Ilse keeps a place for the dye before the Lord's Gold.

All six trials are now built.

## Screenshots

- `/mnt/project-files/pass-168/falling-steps.png`: the steps over the spike floor.
- `/mnt/project-files/pass-168/falling-needle.png`: the needle's thorns and the bell on its slab.

## Tests

- `test_systems.gd`, `test_the_mantra_of_falling_is_steered_all_the_way_down` (new) checks five things:
  - the trial is built for the Glove alone, with a description;
  - all six trials are built;
  - the checker falls to the bell;
  - in the real game, the Guru sends you there and a bot rings the bell in 7.2 s with no set-back. The bot only steers toward waypoints and drops through planks;
  - a clean run beats the mantra time but still needs to be quick.
- `test_every_guru_trial_can_be_cleared_with_the_glove` now covers Falling, so no spot in it is cut off from the bell.
- `test_a_trial_rung_within_its_mantra_dyes_the_cloak` checks that Falling has a mantra time and a dye of its own.
- The trials soak (pass 166) now runs Falling live as well.

Full suite: 3183 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | The last movement course is built: the trials now cover walls, edges, the pogo, wind, stilled water and steering a fall. |
| Combat and enemies | 15 | 98.75 | Unchanged. |
| World and level design | 15 | 98.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Unchanged. |
| Systems | 10 | 98.75 | Unchanged. |
| Audio | 5 | 98.75 | Unchanged. |
| Stability and performance | 5 | 98.75 | Unchanged. |
| Faithfulness | 5 | 98.75 | Unchanged. |

Weighted score: 96.7 (up from 96.65). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Combat, World, Bosses, Systems, Audio, Stability and Faithfulness are tied at 98.75. Combat and World weigh the most (15), and Combat's last pass (161) is the older, so pass 169 takes Combat.
