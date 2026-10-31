# Pass 325: an assist for mercy

Category: Systems (last pass 317).

## Audit

- **Passes 318 to 324.** The off-hand notice (pass 317) still shows once and clears, through `test_an_old_save_with_shield_and_dagger_is_told_of_the_off_hand`. Pass 322 holds the skill pages to the code's numbers.
- **Shops and prices.** Every "Name (N g" the bible gives is a price some shop in `data/shops.json` asks. The grocers' Life Fruit and Mana Dew vary by town, and the bible names one town's price each.
- **Settings.** The options, their steps and the save file are held by the settings tests.
- **Bible 14 and the open questions.** These promise "assist options (extra invulnerability, infinite double jump in Guru Trials only)" and "one tuned difficulty plus assist options". **No assist was built.** Game speed was the one help for a player who found the fights too fast, and slowing everything is a blunt answer to being hit twice in a breath.

## Fix

- New option **Assist: mercy** (Options page, off by default, saved under `[assist]`). It doubles a hit's invulnerability from 0.8 s to 1.6 s (`Settings.MERCY_MULT`, read through the new `Player.hurt_invuln()`), and the hurt blink lasts as long. The hurt pose still lets go after 0.25 s, and the Elixir's rise keeps twice the hit's grace. No tuning number changes.
- The test runner counts a left-on mercy as a leaked setting.
- Test: `test_the_mercy_assist_doubles_a_hits_grace` (test_systems.gd). Off, a second blow 0.9 s later lands. On, it does nothing until 1.6 s have passed. Control returns at 0.25 s either way, the blink matches, and the choice is saved.
- Bible 14: a mercy paragraph, including why the Trials' infinite double jump stays unbuilt (a Trial's miss costs time, never health).
- Screenshot: `/mnt/project-files/pass-325/options.png`. The row sits under Damage numbers, and its help text fits in two lines.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the first promised assist is built. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 326 takes Audio (last pass 318).
