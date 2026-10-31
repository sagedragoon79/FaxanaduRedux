# Pass 332: every guardian's Reward line names its prize

Category: Bosses (last pass 324).

## Audit

- **Health.** Since pass 324, `test_the_guardians_last_as_long_as_their_place` holds the 5.5 table and every "`ClassName`, N HP" in the bible to `MAX_HP`.
- **Telegraphs, phases and openings.** These are held by `test_every_guardian_tell_is_heard_as_it_starts`, `test_every_boss_marks_its_phases_on_the_health_bar`, `test_every_opening_the_table_names_a_parry_for_opens_on_a_parry` and `test_every_guardian_opens_without_a_shield`. Threat is held by `test_the_guardians_hit_as_hard_as_their_zone`.
- **Mercy (pass 325) and Death's boss cap.** The mercy test plays a hit, and the Death tests hold half damage on a boss. Neither depends on the fight.
- **Rewards.** Bible 8 says each boss has "a reward", and each section has a Reward line. **No test read those lines, and four disagreed with `BossArena.BOSSES`.** King Grieve, Borabohra, Shadow Eura and the Evil One's three forms each give a skill point, which the banner has told since pass 220, but their lines left it out. The Foreman's Mattock was told only in passing in section 7's table. Bible 9 counts 12 boss skill points, so a reader of section 8 would count 7.

## Fix

- Bible 8.6, 8.7, 8.8 and 8.9: each Reward line names its skill point. The 8.9 line says one for each of the three forms.
- Bible 7, the Foreman's cell: "Reward: the Mattock (no skill point)".
- Bible 8: a note after "What a win says".
- Test: `test_every_guardians_reward_line_names_its_prize` (test_boss.gd). For each of the 16 entries in `BossArena.BOSSES`, it finds the Reward line in the guardian's own section or paragraph. The line must name the ring, key, blade, armor, ability or stat item, and either its skill point or "no skill point".
- Mutation check: against the old bible the test fails 8 checks. The Foreman has no Reward line, and the other seven failures are the skill points left out of six lines (the Evil One's three forms share one line).

Nothing on screen changed, so there is no screenshot.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: every guardian's reward is written and held. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 333 takes Systems (last pass 325).
