# Pass 199: a thousand coins

Stability's last pass (191) was the oldest apart from Art, so pass 199 takes Stability. Passes 194 to 198 made the deep zones hit up to twice as hard, doubled their gold and added a second hurt sound. I audited stability and performance against those changes.

| Check | Finding | Verdict |
| --- | --- | --- |
| The soaks under the new damage | The zone soaks and the journeys pass in every full run since pass 194. The boss soaks give the player 99,999 health, so threat cannot end their routes, and the journey's player rests and Continues on the way. | fine |
| **Coins** | Gold sprayed as coins of 1 and 5, each a small body that falls, bounces and flies home, then chimes. The Dartmoor vault's 5,000 g chest (Meteor Rise) threw 1,004 coins at once, measured headless: 0.87 s to spawn them and a 27 ms frame. Since pass 197 boss purses reach 1,000 g (about 200 coins) as well. | **fixed: 25 g and 100 g coins; a test caps every purse** |
| The second hurt sound (pass 198) | It plays once per hit, and a hit is followed by 0.8 s of invulnerability, so it adds at most one voice to the pool now and then. | fine |
| Frame budgets | The room-load and journey frame checks pass unchanged. | fine |

## As built

- `Coin.DENOMINATIONS` = 100, 25, 5. `Coin.spray` takes the largest coin that leaves at least as much again for smaller ones, and finishes with singles. So 9 g is still nine coins, and the 5,000 g chest is 61 coins: 54 ms to spawn and a worst frame of 1.5 ms over the next second, measured headless as before.
- A coin is drawn larger the more it is worth: 1, 5, 25 and 100 gold (radius 2.5, 3, 3.5 and 4.5). Screenshot: [coins.png](/mnt/project-files/pass-199/coins.png).
- `game.gd`: a `--coins` screenshot option lays one of each coin ahead of the player.
- Bible 15.3, stability measures: "A thousand coins".
- `test_rooms.gd`, `test_a_big_purse_sprays_few_coins` (new):
  - purses of 3, 9, 10, 137, 1,000 and 5,000 g each add up exactly and make at most 64 coins;
  - a purse under 10 g stays single coins;
  - the big coins fly home like the small ones.

Full suite: 3847 of 3847 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged score: the worst spawn in the game no longer breaks the frame budget, and a test holds it. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 200 takes Movement (last pass 192, now the oldest).
