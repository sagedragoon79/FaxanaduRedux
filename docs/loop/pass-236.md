# Pass 236: a slash cuts the Widow's web

Bosses' last pass (228) was the oldest apart from Art, so pass 236 takes Bosses. I checked each guardian's "Tests:" line in bible 8 against the order you find things, and checked every boss counter that reads a player ability.

| Check | Finding | Verdict |
| --- | --- | --- |
| Phases | Every guardian has 2 or 3 phases marked on its health bar (`PHASES`, tested since pass 98). | holds |
| Telegraphs | Swept as a whole since pass 234. | holds |
| Health and blows by place | `test_the_guardians_last_as_long_as_their_place` and `test_the_guardians_hit_as_hard_as_their_zone`. | holds |
| Rewards | Every win says what it gave (pass 220). | holds |
| Tested abilities against progression | Rokusutahn (Glove), Zoradohna (Mattock pogo), Zorugeriru (Deluge), Pakukame (Stride), Borabohra (Thunder) and King Grieve (Hour Glass) each test an ability found before their arena. Ripasheiku's line said "double jump", but the Wing Boots lie past the fog her Lantern Key parts. | doc fixed |
| **Ripasheiku's web** | Her web reels you toward her for 0.9 s, and the only way to break free was `p.is_dashing`. The dash is the Elven Stride's, found a zone later in the Branches. So at her chapel, with only the Glove and the Mattock, a caught player had no answer and could only wait it out. | **fixed** |

## As built

- `scripts/bosses/ripasheiku.gd`: while she reels you, a slash cuts the strand. She goes back to hanging, and a high, snapping web sound plays. The Stride's dash still breaks free once you have it. It was the only counter in the boss scripts that read a player ability, so no other guardian has this gap.
- `test_a_slash_cuts_ripasheikus_web` (`test_boss.gd`, new). With only the Glove and the Mattock, a dash does nothing, a slash cuts the strand and the pull stops.
- Mutation check: with the slash cut removed, the test fails (she stays reeling).
- Bible 8.3: her Tests line, and the web line in phase 2.
- No visual change, so no screenshot. The strand simply vanishes when cut, the same way it does when the reel times out.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged score: every guardian's counter is now in the player's hands when they meet it. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 237 takes Systems (last pass 229, now the oldest).
