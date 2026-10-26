# Pass 118: the Battle Helmet

Systems (96.5) tied for lowest apart from Art. Pass 117's audit left three of the original's items unbuilt: the Pendant, the Magical Rod and the Battle Helmet.

| Item | In the bible | Verdict |
| --- | --- | --- |
| **Battle Helmet** | 5.2's shield row, tier 4: "secret, +1 mask" | **built this pass** |
| Pendant | not in the bible | left out |
| Magical Rod | not in the bible | left out |

The bible already gives the Battle Helmet a place, which is the top of the shield slot. It was the only cell of the 5.2 gear table still unbuilt. The other three tier-4 cells (the Dragon Slayer and the Battle Suit) are built. In the original, the Pendant raises attack until a late plot point, and the Magical Rod fixes the town's fountain. Neither fits the remake as designed: the fountain is restored by springs, and the skill tree covers attack. They stay out.

## As built

- **Item** `battle_helmet` (`data/items.json`): kind shield, tier 4. It guards 70%, its parry turns shots back like the Magic Shield, and `hp: 20` makes it worth one more mask.
- **Stats:** `refresh_stats` adds the shield's `hp` on top of the base health. The mask comes from the gear, not from `data.max_hp`, so it survives a save and goes away if the slot ever changes.
- **Pickup:**
  - It is laid by `prop: x, y, battle_helmet`, the same way the Joker Key is.
  - Touch it and it goes straight on in the shield's place, as the Dragon Slayer does for the blade, and your health fills to the new top.
  - The banner reads "Battle Helmet: One more mask."
  - It is drawn as a gold-bronze war-helm with white wings.
  - It glows, like the abilities do.
- **Where:**
  - It sits in a hidden pocket in the Threshold, the first room inside the meteor.
  - The pocket is carved into the stone block below the west door, behind fake wall (`secret: 1, 17, 6, 19`), and the shrine stands three tiles east of it.
  - The Black Onyx (found in Dartmoor) shows its seam.
- **Shops:** once you wear it, every shield in a shop shows as owned (tier 4), and no one sells it.

## Screenshots

In `/mnt/project-files/pass-118/`:
- `threshold_outside.png`: the Threshold's west end, with the pocket under fake wall.
- `threshold_inside.png`: the player inside the pocket, with the helmet revealed.

## Tests

`test_the_battle_helmet_is_a_secret_worth_a_mask` (in `test_economy.gd`):
- the prop lays it;
- touching it equips it over a Small Shield;
- max health is 20 more and full;
- it guards 70% and reflects;
- the Magic Shield shows as owned, and no shop sells the helmet;
- the base health is untouched;
- it never comes back;
- it lies in the Threshold inside a `secret:` cover.

## Bible

- 5.2 gains a "Battle Helmet (built pass 118)" block.
- `levels/README.md`: the `battle_helmet` prop.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96.5 | Unchanged. |
| Combat and enemies | 15 | 96.5 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97 | The 5.2 gear table is complete. Every tier-4 cell is built, and the last one is a secret worth finding. |
| Audio | 5 | 96.5 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.75 | Unchanged. |

Full suite: 2315 checks, all passing.

Weighted score: 95.075 (up from 95.025). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Combat, Audio and Stability are tied at 96.5. Pass 119 takes Combat: bible 7 lists two planned foes, the Marsh Hag and the Spire Sentinel.
