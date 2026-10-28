# Pass 218: the sheet past King Grieve

Combat's last pass (210) was the oldest apart from Art, so pass 218 takes Combat. I audited the damage sheet (bible 5.5), `combat_tuning.gd`, telegraphs and hit-stops against passes 211 to 217.

| Check | Finding | Verdict |
| --- | --- | --- |
| Telegraphs, hit-stops (210) | No foe or blow changed since. The wind-up and hit-stop tests pass. | fine |
| Zoradohna's health (212) | 24 par slashes, held by the pass 212 check. | fine |
| The Stride's veil (216) | A world gate. It deals no damage and fights nothing. | fine |
| **The Dragon Slayer at King Grieve (217)** | Pass 217 moved the sword from Zenis to King Grieve's reward. That puts it in hand for everything past his throne: the Meteor Rise, Shadow Eura at the Zenis Gate, and the whole Sunken Spring with the Drowned Warden. The sheet still measured those against the Long Sword +2 (14 a slash, against the Dragon Slayer's 18). Shadow Eura now fell in 14 slashes, under the sheet's floor of 15. The optional Warden fell in 29, so it was no longer the hardest fight. | **fixed: par past Grieve, two healths** |

## As built

- Health changes:
  - Shadow Eura goes from 240 HP to 320, which is 18 Dragon Slayer slashes, the same count she had against the Long Sword.
  - The Drowned Warden goes from 520 HP to 680, which is 38 slashes, also unchanged.
  - Both bosses' phases are fractions of health, so each phase still starts at the same point in the fight.
- `test_combat.gd` changes:
  - `PAR_KIT.sunken` is now the Dragon Slayer.
  - `PAST_GRIEVE_KIT` and `PAST_GRIEVE_BOSSES` measure Shadow Eura against the Dragon Slayer.
  - The damage sheet now checks that the Meteor Rise's foes (Crystal Dwarf, Shade Knight, Clockwork Hound) still take 2 to 7 Dragon Slayer slashes.
- New test, `test_the_sheet_past_king_grieve_holds_the_dragon_slayer`, ties the kit to the game: Grieve's reward is that blade, the Rise lies behind his throne, Shadow Eura waits at the Zenis Gate past it, and the Rise leads down to the Sunken Spring.
- Mutation check: before the health changes, `test_the_guardians_last_as_long_as_their_place` failed on "ShadowEura falls in 15 to 40 par slashes (14)".
- Bible 5.5:
  - The zone table splits Dartmoor and the Sunken Spring into separate rows.
  - The guardians' health table names the new HP values.
  - A new "Past King Grieve" paragraph explains the change.
  - 8.8 notes Shadow Eura's new HP.

Full suite: 4072 of 4072 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged score: the sheet follows the sword to King Grieve, and his successors keep their length. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 219 takes World (last pass 211, now the oldest).
