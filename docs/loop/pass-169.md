# Pass 169: the Clockwork Alpha

Combat, World, Bosses, Systems, Audio, Stability and Faithfulness were tied at 98.75. Combat and World weigh the most (15), and Combat's last pass (161) was the older, so pass 169 takes Combat. I audited combat and the bestiary against bible 5 and 7 and the newest content (passes 161 to 168).

| Check | Finding | Verdict |
| --- | --- | --- |
| Telegraphs | every tell in the game is still at least `Enemy.MIN_TELEGRAPH` | fine |
| Executioner and `Enemy.punishable()` (pass 163) | every boss names its opening; the table in section 8 matches | fine |
| Zenis remixes (pass 161) | corrupted foes keep their own tells and openings | fine |
| The trials (passes 162, 168) | hazards set you back and never hurt; no foe stands in a trial | fine |
| **Mini-bosses** | Bible 7 plans about one per zone: the Foreman, the Marsh Hag Matriarch, the Bark Knight Captain and the Clockwork Alpha. Only the Foreman was built. Dartmoor's Clockwork Hounds had no sire, and the zone had no fight between its foes and King Grieve. | **built** |

## As built

**The Clockwork Alpha** (`scripts/bosses/clockwork_alpha.gd`) is a great brass hound with a crown collar and a winding key, code-drawn at 3x. It waits in **Alpha's Den** (`levels/dartmoor/alpha_den.room`, 57,-6, 40x23). You reach the den by dropping through a plank lid laid over the King's Kennels' old spiked drain. It has 260 HP, and its plating halves every blow until it is open.

- **Pounce** (0.6 s tell): a leap with a bite of 18, then a 0.55 s skid.
- **Charge** (0.7 s tell): it runs at 300 px/s, or 340 in phase 2, with a body blow of 20. If it reaches a wall it jams there for 1.6 s.
- **Howl** (phase 2, 0.8 s tell): it winds a Clockwork Hound pup out of a grate at either end of the den, never more than 2 at once. The pups run down when it dies.

It is open when a parry flips it (1.5 s), when it is jammed, or while the Hour Glass is turned, because clockwork stops dead in stopped time. That gives Dartmoor's own tool, the glass, a use in combat. Below half its tells are 25% shorter. It plays the `miniboss` theme and gives a Life Fruit, but no skill point. It stays out of the Boss Rush.

## Screenshots

- `/mnt/project-files/pass-169/den.png`: the Alpha's banner as you land in the den.
- `/mnt/project-files/pass-169/fight.png`: the Alpha trotting at you across the den floor.

## Tests

`test_boss.gd` adds eight new tests:

- `test_the_alpha_waits_in_a_den_under_the_kings_kennels`: the kennels' shaft leads to the den, the den is a mini-boss arena, and dropping in wakes the Alpha.
- `test_the_alphas_tells_are_fair`: every tell is at least the minimum, in both phases.
- `test_the_alphas_plating_turns_blows_until_it_opens`: blows are halved while it is closed and full once it is flipped.
- `test_the_hour_glass_stops_the_alpha_dead`: in stopped time it does not move, and it takes full blows.
- `test_the_alpha_charges_into_the_wall_and_jams`
- `test_the_alpha_pounces_on_the_player`
- `test_the_alpha_winds_pups_in_its_second_phase`: no more than 2 pups, and they die with it.
- `test_the_alpha_gives_a_life_fruit`: max HP grows by a Life Fruit, and no skill point is given beyond rank-ups.

`test_reachability.gd` now lists the den with the Mattock and Thunder rooms. The den passes the soft-lock check, so you can always climb back out through the shaft.

Full suite: 3217 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Dartmoor has its mini-boss, a fight that turns the zone's own Hour Glass into a weapon. |
| World and level design | 15 | 98.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Unchanged. |
| Systems | 10 | 98.75 | Unchanged. |
| Audio | 5 | 98.75 | Unchanged. |
| Stability and performance | 5 | 98.75 | Unchanged. |
| Faithfulness | 5 | 98.75 | Unchanged. |

Weighted score: 96.7375 (up from 96.7). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

World, Bosses, Systems, Audio, Stability and Faithfulness are tied at 98.75. World weighs the most (15), so pass 170 takes World. The Marsh Hag Matriarch and the Bark Knight Captain are still unbuilt.
