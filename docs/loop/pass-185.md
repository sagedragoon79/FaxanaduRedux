# Pass 185: a helmet slot

Sean's note (2026-10-27): "That is odd regarding the helmet/shield slot. I feel like helms should have their own category. Or just have the helm unlock the extra health and maybe a 10% damage reduction. I think players would still want to use the 'magic shield'." Combat's last pass (177) was the oldest, and this is a gear and combat change, so pass 185 takes Combat.

| Check | Finding | Verdict |
| --- | --- | --- |
| **The Battle Helmet** | It sat in the shield slot as a fourth-tier shield. Putting it on took the Magic Shield out of your hand, and every shield then showed as owned, so a player had to choose between a mask and the Magic Shield's reflecting parry. | **own slot** |
| Old saves | A save with the helmet as its shield would keep a shield-slot item that no longer guards | **migrated** |
| Paper-doll | Sean is drawing the hero bare-headed with gear as layers; nothing marked where the head is in each frame | **built** |

## As built

- **A fourth equipment slot**, `equipment.helmet` (a new game and every older save get `""`).
- **The Battle Helmet** (`data/items.json`, kind `helmet`): +1 mask (20 HP) and 10% less damage. It no longer guards or parries.
- **Stacking:** armor and helmet multiply what they let through: `defense = 1 - (1 - armor) x (1 - helmet)`. Under the Battle Suit that is 64%; with no armor, 10% (`GameState.refresh_stats`).
- **Pickup:** it goes on the head, and the shield stays in hand. Its card says so.
- **Shops:** helmets count as gear (`Shop.status` and `Shop.buy`). With the helmet on, shields are for sale again.
- **Saves:** a save wearing it as a shield wears it as a helmet and gets the Magic Shield in hand, which is the guard and parry it had (`GameState.sanitize`).
- **Drawing:**
  - The helmet is a code-drawn layer on the crown of the head (`PlayerVisual._draw_helmet`), in the colours of Sean's reference: sea-green steel, a gold brow band and cheek guard, a swept wing crest and cyan runes.
  - The pickup was redrawn in the same colours.
  - `autosprite_import.head_point` finds the crown in each frame's pixels on import:
    - The cloak is masked out.
    - Blades and fists are opened away.
    - A crown that jumps over both neighbours drops back.
  - Every frame of `player.json` now carries a `head` point (manifest flag `"head": true`), so a drawn helmet sheet can sit on the same point later.
- Bible 5.2 (the gear table, the Battle Helmet entry) and `levels/README.md`.

## Screenshots

- `/mnt/project-files/pass-185/battle_helmet_worn.png`: idle, run, a lunge and a wall jump, with the helmet on.
- `/mnt/project-files/pass-185/battle_helmet_pickup.png`: the pickup at the Threshold.

## Tests

- `test_economy.gd`, `test_the_battle_helmet_is_a_secret_worth_a_mask` (rewritten):
  - It goes in the helmet slot and the Magic Shield stays in hand.
  - +1 mask.
  - 64% under the Battle Suit, 10% alone.
  - Shields can still be bought with it on.
- `test_systems.gd`, `test_a_save_with_the_helmet_in_the_shield_slot_moves_it_to_the_head` (new).
- `test_animation.gd`, `test_every_hero_frame_marks_the_crown_for_the_helmet` (new): every frame has a crown on solid pixels.
- `test_rooms.gd`, `test_late_additions_survive_a_save_round_trip`: the helmet slot survives a save.

Full suite: 3445 of 3446 checks passed, with no script errors. The one failure was `test_every_save_field_survives_a_round_trip`, which now saves a helmet too (and its mask in the max health); fixed, it passes on its own.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged: no gear choice now costs the Magic Shield's parry. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 186 takes World (last pass 178, now the oldest).
