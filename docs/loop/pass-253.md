# Pass 253: every skill point counted

Systems' last pass (245) was the oldest apart from Art, so pass 253 takes Systems.

| Check | Finding | Verdict |
| --- | --- | --- |
| Save shape | Every key `fresh()` holds is coerced back by `sanitize`. The purse (pass 250), keys, trials, Gurus, pins and gear are each checked by shape. | holds |
| Respec price, rank thresholds | `Skills.respec_cost` is 200 g a time, capped at 2,000 g, and `RANK_XP` matches bible 9. | holds |
| **Skill points against bible 9** | The bible's count was 29 points: 15 ranks, "9 from the main bosses" and 7 from mantras. But twelve guardians' rewards give a point. These are the six zone bosses, King Grieve, Shadow Eura, the Drowned Warden, and each of the Evil One's three forms. So the game gives 34. The bible's "54 in total" was the planned tree, and the built one costs 49 over 27 nodes. A test asserted "more than 29", so the drift passed. Nothing in the game told a player how many points remained to find. | **fixed** |

## As built

- `World` catalogs each room's Mantra Shards (`mantras`).
- `Completion.skill_points(catalog)` counts every source: the ranks past Novice, the guardians' `skill_points`, and the rooms' Mantra Shards plus one for each Guru Trial, three to a point. Earned is the points held plus the cost of the skills learned, so learning and unlearning never move it. `Completion.tally` carries it.
- The Journey page has a new row: "Skill points", earned against 34. Its detail reads "From ranks, guardians and whole mantras. The tree costs more than all of them."
- `test_the_journey_counts_every_skill_point_the_game_gives` (`test_systems.gd`, new): 15 ranks, 12 guardians, 15 shards and 6 trials make 34. The tree costs more than that, learning or unlearning two skills leaves the earned count alone, and the Journey row reads "3 / 34". `test_act_three_skills_chain_and_apply` now asserts more than 34.
- Bible 9: the boss line names the twelve, the total is 34, the built tree costs 49, and the later notes say "34 (counted as 29 until pass 253)".
- Screenshot: `/mnt/project-files/pass-253/journey.png`. The new row sits under Mana Dew, aligned with the others.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the skill economy's real total is in the bible, held by a test and shown on the Journey page. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 254 takes Audio (last pass 246, now the oldest).
