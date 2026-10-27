# Pass 175: Forepaw's hospital and larder

Faithfulness (98.75, weight 5) was the lowest category apart from Art. I audited the newest content (passes 168 to 174) against the original Faxanadu, and then the towns against the original's towns.

| Check | Finding | Verdict |
| --- | --- | --- |
| Clockwork Alpha and Bark Captain (passes 169, 171) | new mini-bosses in the Dartmoor kennels and the Branches; the bible's rule is that names reuse the original's monster names where they exist, and neither has one | fine |
| The Proving Scar (pass 170) | a remake gauntlet in Zenis, the Evil One's fortress; nothing in it goes against the original | fine |
| Journey page, mini-boss sounds, stability work (passes 172 to 174) | UI, audio and tests; no bearing on the original | fine |
| Rings, the Dragon Slayer and the Demon Ring | the original's Fraternal Castle Guru gives the Demon Ring for the Dragon Slayer; the remake gives it to King Grieve's fall, a choice the bible has recorded since the critical path was set (4.2) | fine |
| **Forepaw's town** | The original's Forepaw had a hospital (treatment for 500 gold), a meat store, an item shop and a key shop. The remake's Forepaw had only the smith and the surveyor, so it was also the one town without an item shop, which bible 10.2 promises for every town. | **built** |

## As built

- **The Forepaw Larder:** Provisioner Dagny, a new dwarf by the Guru, sells an Elixir (1,500 g) and the Queen Key (400 g). Her greeting offers the original's dried meat. Forepaw's smith already sells the ointment and the Jack Key.
- **The hospital:** Physician Halvar, in front of the town's second house, is the original's hospital.
  - Talking to him when you're hurt, drained or poisoned makes health and magic whole and draws the poison out (`Npc.treat`, a new NPC role `physician`). It costs nothing: "Forepaw does not charge the one who silenced the drill."
  - It neither saves nor refills the Red Potion flask; that stays the Guru's rest. When there is nothing to mend, he only talks.
  - This is a deviation, recorded in the bible: the original charged gold, but a paid heal beside a free rest would never be bought.
- Both have new lines and new looks, drawn by `castgen.py` from `data/npcs.json`.

## Screenshots

- `/mnt/project-files/pass-175/forepaw-west.png`: Dagny beside the hero, between the Guru and the first house.
- `/mnt/project-files/pass-175/forepaw-physician.png`: Halvar in his white coat beside the Elder, before the hospital house.

## Tests

- `test_economy.gd`, `test_forepaws_physician_mends_you_and_its_larder_sells` (new). It checks that:
  - he only talks when you're whole;
  - he mends health, magic and poison;
  - he takes no gold, doesn't save and doesn't refill the flask;
  - both NPCs are in Forepaw;
  - the Larder's stock is right.
- `test_every_npc_and_shop_entry_is_valid`: a physician must have both `lines` and `lines_treated`.

Full suite: 3301 checks, all passing, with no script errors in the log.

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
| Faithfulness | 5 | 99 | Forepaw keeps the original's hospital and its shop, and every town now has an item shop. |

Weighted score: 96.8625 (up from 96.85). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Every category apart from Art is now at 99. Ties break by weight, so pass 176 takes Movement (weight 20, last pass 168).
