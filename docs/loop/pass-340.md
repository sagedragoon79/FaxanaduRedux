# Pass 340: every guardian's numbers, written and held (Bosses)

## Audit

The Bosses category was last audited in pass 332, which named every guardian's prize. This pass read bible 8 against `scripts/bosses`. Health is held: since pass 324, every `(ClassName, N HP` the bible names is checked against `MAX_HP`. Every wind-up in a guardian's section is one of its script's constants, so nothing in 8 disagrees with the code. The gaps:

- Rokusutahn's section (8.1) gave none of his three wind-ups (0.9 s lunge, 0.8 s plunge and dangle), not his health (600), and not the mark where his second phase starts (60%).
- Pakukame's section gave no mark for its third phase (25%).
- No test read any guardian's phase marks or wind-ups from the bible. Tests used the scripts' own `PHASES` and constants, so a retuned mark or tell would have left the bible behind.

## Fix

- Bible 8: a new table, "Every guardian's numbers, as built (pass 340)", gives each of the 16 guardians (with the Evil One's three forms) its health, phase marks and named wind-ups. Wind-ups are listed before a phase quickens them.
- Bible 8.1: Rokusutahn's body (600 HP over 26 segments), his lunge tell (the wall glows and cracks for 0.9 s), "Phase 2 (below 60%)" and the 0.8 s dust column before a plunge or dangle.
- Bible 8.5: "Phase 3 (below a quarter)".
- `test_every_guardians_numbers_are_written_in_bible_8` (test_boss.gd) checks several things:
  - every boss script with `PHASES` has a row;
  - each row matches `MAX_HP` (or `VEIN_HP` for the veins), `PHASES` and every `*TELL*` or `WINDUP` constant (not `TELL_SEEN` or a phase's `_P2`/`_P3` tell);
  - every wind-up is at least `Enemy.MIN_TELEGRAPH`;
  - every "Phase N (below ...)" line in sections 8.1 to 8.8 matches `PHASES[N - 2]` (half, a quarter, a fifth, or a percent).
- No boss script changed (`zorugeriru.gd` untouched).

Mutation check: with Rokusutahn's second mark at 55%, Borabohra's third at 30% and King Grieve's chop tell at 0.65 s, the test fails five times, naming all three.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: every guardian's health, phase marks and wind-ups are written in bible 8 and held to its script. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 341, Systems: audit passes 334 to 340 for systems facts (shops, skill tree, saves, settings) in the bible that no test holds or that the code disagrees with.
