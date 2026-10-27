# Pass 167: the farewell

Faithfulness (98.5, weight 5) was the lowest category apart from Art. I audited the remake against the original Faxanadu (the rubric's checklist, bible 1, 2, 5.4, 8.9 and 11) and the newest content (passes 161 to 166).

| Check | Finding | Verdict |
| --- | --- | --- |
| Towns, Gurus, ranks, rings, keys, springs, the original bosses, the Evil One | unchanged since pass 159: all eight towns with a Guru and a shop, 16 ranks, 4 rings, 5 keys, 3 springs, every boss | fine |
| Equipment | the original's four blades, four armors and four shields, with the original's names | fine |
| Zenis remixes (pass 161) | Zenis, the Evil One's fortress, now fields every zone's foes, as the original's last stretch revisits its bestiary | fine |
| The Hour Glass trial (pass 162) | the remake's glass stops water and shots, not foes; this is a design choice the bible records (A8) | fine |
| Executioner, mantra dyes, reward sounds (passes 163 to 165) | additions the bible plans; nothing in them goes against the original | fine |
| **The ending's last beat** | Faxanadu ends with the hero thanked by Eolis and then walking away from it, a wanderer again, as he came. The remake's epilogue stopped at "And in Eolis, the fountain fills." The hero was never seen again, and nothing said that he moved on. | **built** |

## As built

- **`EndingScreen.FAREWELL`:** two cards close every ending, after the secret one's too:
  1. "In Eolis, the King waits by the full fountain to thank you."
  2. "But the wanderer is already on the east road, walking on."

  The text is new, and nothing is taken from the original.
- **The wanderer:** while these two cards show, the hero walks out of the foot of the Tree and off the east edge. He is drawn with the player sheet's own run cycle at 0.6x as a dark shape against the dawn (`_draw_wanderer`, `wanderer_x`, 46 px/s). He is gone before the credits climb.
- The plain epilogue is now six cards (24 s), and the secret one nine.

## Screenshots

- `/mnt/project-files/pass-167/farewell-king.png`: the King's card, with the wanderer leaving the Tree.
- `/mnt/project-files/pass-167/farewell-road.png`: the road card, with the wanderer near the east edge.

## Tests

- `test_systems.gd`, `test_the_ending_closes_on_the_wanderer_walking_on` (new). For the plain and the secret ending, it checks that:
  - the farewell closes the epilogue;
  - no one walks before the farewell;
  - the wanderer sets out from the foot of the Tree and is off the east edge before the climb, which follows;
  - the walk is the hero's own sheet;
  - both cards fit the screen.
- The ending tests (`tells_climbs_and_thanks`, `pause_skips`, `secret_ending_adds_the_sources_cards`) now count the farewell. The secret test checks that the farewell still comes after the Source's cards.

Full suite: 3166 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Unchanged. |
| Combat and enemies | 15 | 98.75 | Unchanged. |
| World and level design | 15 | 98.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Unchanged. |
| Systems | 10 | 98.75 | Unchanged. |
| Audio | 5 | 98.75 | Unchanged. |
| Stability and performance | 5 | 98.75 | Unchanged. |
| Faithfulness | 5 | 98.75 | The ending closes as the original's did: Eolis would thank the hero, and he walks on. |

Weighted score: 96.65 (up from 96.6375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Every category apart from Art is now at 98.75. The tie breaks by weight, so pass 168 takes Movement (weight 20, last pass 160).
