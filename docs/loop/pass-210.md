# Pass 210: the kill, hurt and fall hit-stops in the tuning

Combat's last pass (202) was the oldest apart from Art, so pass 210 takes Combat. I audited every hit-stop in the code against bible 5.3 and 6.7, and passes 203 to 209.

| Check | Finding | Verdict |
| --- | --- | --- |
| Telegraphs | Each foe's wind-up test (`test_enemies.gd`, against `Enemy.MIN_TELEGRAPH`) and the bosses' `*_telegraphs_are_fair` tests pass. No foe was added since. | fine |
| Guardians' blows and health (196, 204) | Both sheets are held by tests. | fine |
| The Pendant and Rod (201), big coins (206) | Damage and sound only, all tested. | fine |
| Slash, heavy, parry and pogo hit-stops | These live in the tuning and are pinned (202, 208). | fine |
| **A foe's kill, being hit, your fall** | They hold 80, 150 and 350 ms, but each was a bare number in `enemy.gd` or `player.gd`. CLAUDE.md says combat numbers live in `combat_tuning.gd`. Bible 6.7's hit-stop line named neither the kill nor the fall, and the hurt test compared against a literal `0.15`. | **moved into `CombatTuning` and pinned** |

## As built

- `CombatTuning` gains three values, and `Enemy.die` and `Player.take_damage`/`_die` now read them:
  - `kill_hitstop` 0.08;
  - `hurt_hitstop` 0.15;
  - `death_hitstop` 0.35.
- Tests:
  - `test_the_starting_combat_values_match_bible_5_3` holds the three values to the bible.
  - `test_a_kill_and_a_fall_hold_their_hit_stops` (new) kills a dwarf and fells the player, and checks each hit-stop in play.
  - `test_being_hit_matches_the_bible` reads the tuning.
- Mutation check: a 70 ms kill in `enemy.gd` fails the new test.
- Bible 6.7: the hit-stop line lists the kill, the hit and the fall, and notes where the three values now live. Each boss's own blows and each spell's hits keep their bespoke hit-stops.
- No numbers changed, so the feel is unchanged.

Full suite: 4024 of 4024 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the core hit-stops are now in the tuning and held to the bible. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 211 takes World (last pass 203, now the oldest).
