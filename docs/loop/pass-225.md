# Pass 225: shields ward sorcery, as in the original

Faithfulness's last pass (217) was the oldest apart from Art, so pass 225 takes Faithfulness. I audited the remake against the original's NES manual (the Internet Archive's text of *Faxanadu (USA)*) and against passes 218 to 224.

| Check | Finding | Verdict |
| --- | --- | --- |
| Passes 218 to 224 | Damage sheet, Sky Steps purse, boss banners, the Dragon Slayer's save record, the win fanfare, the Hydra soak and the wind. None changes an original name, item or story beat. | fine |
| Weapons, armor and magic | All of the manual's weapons, armors and five spells are in the game, renamed only where the bible says (5.2). | fine |
| Shops and buildings | The castle's gold, the Gurus' ranks and mantras, the doctor (Forepaw's hospital, pass 175), the meat and key shops, and an item shop in every town are all in (the checks of passes 201 and 209). | fine |
| Death | The manual sets your gold and experience back by rank. The remake drops part of your gold where you fall instead. This is a recorded deviation (bible 5). | fine |
| Glove | The manual's Glove raised attack for a while. The remake's is the Climbing Glove (A1). The Temper Blade and the Pendant cover attack. | recorded |
| **Shields** | The manual gives each shield one job: it resists enemy magic (Small 50%, Large 75%, Magic 90%, Battle Helmet "almost all"). The remake's shields guarded and parried, but a hex you didn't block landed whole. The shields' original purpose was missing. | **fixed** |

## As built

- `ward` on each shield in `data/items.json`: Small 0.2, Large 0.3, Magic 0.4. The Battle Helmet has 0.2, and the total is capped at `GameState.MAX_WARD` (0.6). `refresh_stats` sets `Player.magic_ward`. A shield on the back of a two-hander wards nothing.
- `Player.receive_attack` lessens a blow from the group `Player.MAGIC` by the ward, whether you are guarding or not. The ward is below the original's figures so that the guard, the parry and the damage sheet still matter.
- Sorcery: the Marsh Hags' and the Matriarch's hex (`MireGrasp`), Shadow Eura's bolts, King Grieve's crystal shards and the meteor core's beam. Bites, blows, breath, storm and thrown things are not sorcery.
- Each shield's and the helmet's description names its ward. All four still fit the Equipment page's three lines. The Magic Shield's text was shortened to fit.
- New test `test_a_shield_wards_a_foes_sorcery` (`test_economy.gd`) checks the wards, the cap, the two-hander and a real hex (20 lands as 16 through the Small Shield, and a blow still lands as 20). It also checks that the four casters' scripts join the group. Mutation check: with the ward off, the hex check fails.
- Bible 5.2 (the table and a "Shields ward sorcery" note) and the 15.3 Faithfulness row.

No visual change, so no screenshot.

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
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: the shields do what the original's did. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 226 takes Combat (last pass 218, now the oldest). Worth checking that the ward leaves the damage sheet's hardest sorcery blows sensible.
