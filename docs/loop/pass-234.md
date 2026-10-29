# Pass 234: every wind-up, held as a whole

Combat's last pass (226) was the oldest apart from Art, so pass 234 takes Combat. I audited the telegraph rule first (CLAUDE.md: enemies must telegraph for at least `Enemy.MIN_TELEGRAPH`, 0.35 s), then the tuning sheet, zone threat and variety.

| Check | Finding | Verdict |
| --- | --- | --- |
| **Telegraphs as a whole** | All 78 named wind-ups (every `*TELL`, `WINDUP` and `WARN` constant in `scripts/enemies` and `scripts/bosses`) meet 0.35 s but one, and all 14 guardians that quicken their tells by phase clamp them with `maxf(Enemy.MIN_TELEGRAPH, ...)`. But the rule was only tested piecemeal, one foe or boss at a time. A new foe, or a tell retuned under the floor, would pass every test. | **fixed** |
| The crystal spike's 0.18 s glow | Below the floor, but it is a follow-on warning: all four casters (the Crystal Dwarf, the Evil One's avatar and heart, and King Grieve) wind up for at least 0.35 s, even at their quickest phase, before any spike spawns. The glow only says where each spike will rise. | holds, now documented |
| `combat_tuning.gd` against bible 5.3 | Held by `test_the_starting_combat_values_match_bible_5_3`. | holds |
| Zone threat and the damage sheet | Held by the damage-sheet tests since passes 225 and 226. | holds |
| Variety | 24 foe types across the zones, each with its own tell and counter. | holds |

## As built

- `test_every_wind_up_in_the_game_is_fair` (`test_enemies.gd`, new). It checks that:
  - every named wind-up in every foe and guardian script lasts at least `Enemy.MIN_TELEGRAPH`;
  - every `func tell(` clamps to it;
  - the crystal spike's glow is the one listed exception, with exactly four casters;
  - each caster's tell is fair at its quickest phase. King Grieve's frantic burst tell is 0.45 × 0.65 = 0.29 s raw, and his clamp lifts it to 0.35 s.
- Mutation check: a Hornet wind-up of 0.3 s, and the avatar's tell with its clamp removed, each fail the test.
- Bible 7 (enemy design) and the 15.3 Combat row name the test and the spike exception.
- No visual change, so no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the telegraph rule is now swept across the whole game. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 235 takes World (last pass 227, now the oldest).
