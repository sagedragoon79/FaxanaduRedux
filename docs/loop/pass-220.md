# Pass 220: every boss's win says what it gave

Bosses' last pass (212) was the oldest apart from Art, so pass 220 takes Bosses. I audited bible 8 (phases, telegraphs, openings, rewards, arenas) and the 5.5 sheets against passes 213 to 219.

| Check | Finding | Verdict |
| --- | --- | --- |
| King Grieve's reward (217) | The Dragon Slayer goes straight into your hand, with the Demon Ring. Tested. | fine |
| Shadow Eura's and the Warden's health (218) | 18 and 38 Dragon Slayer slashes. Their phases are fractions, so their pacing holds. | fine |
| Telegraphs and openings | The `*_telegraphs_are_fair` tests and `punishable()` (pass 163) pass. No boss's moves changed. | fine |
| Stale references to the Heart Gate sword | The bible, the items table and the signs agree since pass 217. | fine |
| **The win banner** | `BossArena._on_defeated` picks one banner per reward kind. Shadow Eura and the Evil One's avatar, veins and heart have a story line in `BOSSES` but no prize, so they fell to the plain branch, which shows only "+1 skill point". Their lines were written and never shown. Ripasheiku, Borabohra, the Drowned Warden and King Grieve show their prize's line and never said they gave a skill point. | **fixed** |

## As built

- A boss with a line and no prize shows its line. A boss whose banner tells a story also shows its skill point, as a toast under the banner (`BossArena.point_line`). Bosses with no line are unchanged ("Elf Ring, +1 skill point").
- `test_every_guardians_win_says_what_it_gave` (`test_soak.gd`, new):
  - It wins every arena but the Evil One's last (whose win starts the ending) and listens to the banner and toasts.
  - It checks that each line is shown and each skill point is told.
  - It checks that every line, the Evil One's included, fits the banner (at most 620 px at size 10).
- Mutation check: with the old banner code it fails, naming shadow_eura's lost line and the skill points of king_grieve, borabohra, ripasheiku and drowned_warden.
- The banner sits at the top of the screen and the toast near the bottom, so the two never overlap. Both were already drawn this way, and neither one's drawing changed.
- Bible 8: a "What a win says" paragraph.

Full suite: 4089 of 4090 checks passed locally. The one failure was `test_hydra_fight_soak_stays_lean` ("the soak reached the flood"). It runs before the new test and touches no reward code, and it passed twice when run on its own, so it is an order-dependent flake in an untouched test. CI has the final say.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: the mirror's and the meteor's lines are seen, and every win names its skill point. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 221 takes Systems (last pass 213, now the oldest).
