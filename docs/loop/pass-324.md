# Pass 324: the bible names each guardian's real health

Category: Bosses (last pass 316).

## Audit

- **Passes 317 to 323.** No boss changed. Pass 314's openings without a shield and pass 316's dagger reach still hold for every guardian, through `test_every_guardian_opens_without_a_shield` and `test_the_rune_dagger_reaches_every_guardian`.
- **Telegraphs, threat and drops.** These are held by `test_every_wind_up_in_the_game_is_fair`, `test_the_guardians_hit_as_hard_as_their_zone` and the drop tests.
- **Health.** `test_the_guardians_last_as_long_as_their_place` holds each guardian to 15 to 40 par slashes. **Nothing held the bible's own figures to the code**: the par-slash table in 5.5, and the health named beside each boss's class. One was stale: the Drowned Warden's room note (4, the Wellspring) still said "`DrownedWarden`, 520 HP", though pass 218 raised it to 680.

## Fix

- Test: `test_the_guardians_last_as_long_as_their_place` (test_combat.gd) now also checks two things. Each guardian's count in 5.5's table must equal its computed par slashes. Every "`ClassName`, N HP" in the bible must equal that boss's `MAX_HP`. It failed on the Warden's note. As a mutation check, Ripasheiku at 300 HP fails the table row ("20 par slashes, and the code 24").
- Bible: the Warden's note now reads 680 HP (520 until pass 218), and 5.5 says what the test holds.

No boss changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the guardians' health on paper is now the health in the game. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 325 takes Systems (last pass 317).
