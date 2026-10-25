# Pass 98: Combat feel

Combat (92.75) was the lowest category apart from Art. This pass audits combat against bible section 5 and the combat lines of 6.7, item by item, then builds the gaps.

## Audit

| Item | Bible | Status and evidence |
| --- | --- | --- |
| Combo: 3 ground hits, 2 air, heavy finisher | 5.3 | Present; `test_three_hit_ground_combo`, `test_air_combo_is_two_hits`. |
| Combo window, cooldowns, attack buffer | 5.3 table | Match `combat_tuning.gd`; `test_combo_resets_after_window`, `test_attack_press_is_buffered`. |
| Recoil on hit (player pushed back) | 5.3 | `slash_recoil` 90 px/s on a side hit. |
| Up-slash, Rising Cut launch | 5.3 | Present and tested. |
| Parry: 0.12 s window, 140 ms hit-stop, 1 s stagger, +6 MP | 5.3 | Present; `test_parry_staggers_and_prevents_damage`. |
| Guard: 50%, 8 MP, 40% walk | 5.3 | Present; `test_guard_halves_damage_and_costs_mp`. |
| Damage taken: 0.8 s invulnerability, 0.15 s hit-stop, knockback | 5.3 | Present; `test_clean_hit_knocks_back`. |
| Damage taken: screen flash | 5.3 | **Gap.** Only the player sprite flashed red; nothing on screen. Built (below). |
| Enemy hit flash and knockback (heavy 1.8x) | 6.7 | Present in `Enemy.take_hit`. |
| Enemy telegraphs >= `Enemy.MIN_TELEGRAPH` | 7 | Asserted for every enemy in `test_enemies` and every boss in `test_boss`. |
| Hit-stop 50 / 90 / 140 / 350 ms | 6.7 | Present at those values. |
| Hit-stop 200 ms on a boss stagger | 6.7 | **Gap.** Nothing used it. Now each phase break holds 200 ms. |
| Shake 0.15 light, 0.3 heavy | 6.7 | Present. |
| Rumble on hits, damage, parry | 6.7 | Present. |
| Spark burst on hit | 6.7 | **Weak.** A puff of six dots at the foe's middle, lost under its white flash. Replaced by a real impact spark (below). |
| Danger at low health | — | **Missing.** Nothing told you one more hit would kill you except the masks. Built (below). |
| Gold magnet 0.4 s | 5.3 | Present. |

## What changed

- **Impact sparks** (`HitSpark`): every melee hit throws a spark where the blade meets the foe. It has a white core, an opening ring, and five rays fanned along the swing (one kicks back). An orange rim lets it read over the foe's white flash. It holds through the hit-stop, so the frozen frame shows the impact, and it lasts 0.14 s. The heavy finisher's spark is 1.6x. One spark is thrown per foe per swing, and none on a miss.
- **Hurt edge flash** (`GameHud`): taking damage flashes a red glow around the screen's edge that fades in about 0.4 s. It never covers the middle. The Flashes option scales it and can turn it off. Healing doesn't flash.
- **Low health:** at one mask (20 HP) or less, a muffled lub-dub heartbeat (new `heartbeat` sound) plays every 0.85 s, and the edge pulses faintly red in time with it. It stops when you heal above a mask. The numbers are `low_health` and `heartbeat_interval` in `combat_tuning.gd`.
- **Boss stagger hit-stop:** a phase break now holds the world for 200 ms (`BossArena.PHASE_HITSTOP`), the bible's boss-stagger value.
- `Feel.last_hitstop` records the last hit-stop for tests.
- Bible 5.3 (damage taken, low health, table row) and 6.7 (hit-stop, flash, particles) are updated.

## Tests

- `test_combat.gd`:
  - `test_a_hit_sparks_where_the_blade_meets_the_foe`
  - `test_a_miss_throws_no_spark`
  - `test_being_hurt_flashes_the_screen_edge_red`
  - `test_low_health_beats_and_pulses`
- `test_boss.gd`: the phase-break test now checks the 200 ms hit-stop.
- `levels.py --check` passes with the new sound.

Full suite: 1832 checks, all passing.

Screenshot: `/mnt/project-files/pass-98/hit_spark.png` (a slash landing on the gym dummy at one mask, with the red edge pulse).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 93.25 | Unchanged. |
| Combat and enemies | 15 | 93.75 | Hits land with a visible impact; being hurt and being in danger are felt as well as shown. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98 | Phase breaks hold the frame. |
| Systems | 10 | 93.25 | Unchanged. |
| Audio | 5 | 93.75 | The heartbeat. |
| Stability and performance | 5 | 93 | Unchanged. |
| Faithfulness | 5 | 96 | Unchanged. |

Weighted score: 93.24 (up from 93.05; 93.2375 unrounded).

## Next

Stability (93) and Systems (93.25) are now the lowest apart from Art. Pass 99 takes Stability: a long soak through every zone with save and load mid-run, looking for leaks, stray errors and frame spikes.
