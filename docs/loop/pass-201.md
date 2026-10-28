# Pass 201: the Pendant and the Magical Rod

Faithfulness's last pass (193) was the oldest apart from Art, so pass 201 takes Faithfulness. I audited faithfulness to the original against the rubric's checklist (15.3: towns, Gurus, ranks, rings, keys, springs, the original bosses, the Evil One) and against the original's finds, with passes 194 to 200 in view.

| Check | Finding | Verdict |
| --- | --- | --- |
| Zone threat and the gold sheet (passes 194 to 197) | In the original, deeper foes hit harder and paid more too. | fine |
| Coin denominations (pass 199) | The original's gold was a number, not coins. Coins worth more are a modern way to show it. | fine |
| **The original's relics** | Pass 193 put the twelve pieces of gear on record. Two more of the original's finds were in no shop and had never been in the remake. The **Pendant** lay at the end of the Tower of Suffer, in a corner of its guardian's room. The **Magical Rod**, up a ladder in Conflate, raised Deluge from 6 to 9. | **built: both, found once and kept** |
| **The checklist as a whole** | Each item was checked by hand in earlier audits (passes 145 to 175), but no single test held the rubric's list. A lost Guru or a renamed rank would only show up in the next audit. | **built: one test of the whole checklist** |
| Ranks, rings, keys, towns, springs, Gurus, bosses | All present (the new test checks them). | fine |

## As built

- **The Pendant** lies in the far corner of the Matriarch's Mire (`mist/hag_mire`, 37,16), the Mist's optional guardian's room. Every blade hit lands a tenth harder (`CombatTuning.pendant_mult` 1.1, in `Player.blade_mult`).
  - The original's Pendant was meant to raise attack, but a slip in its code lowered it instead. The remake gives it the effect it was meant to have, small enough that the damage sheet holds without it.
- **The Magical Rod** lies on Conflate's high plank (73,7), up a new ladder at the east end of the town, as the original's was. Deluge bolts strike half again as hard (`rod_deluge_mult` 1.5: 12 to 18, as 6 to 9).
- Both are `prop:` finds (`Room.FOUND_PROPS`), so the completion count includes them as treasures. Both are drawn in code: a gold locket with a green leaf-stone, and a pale wand with a water-blue orb. Screenshots: [conflate_rod.png](/mnt/project-files/pass-201/conflate_rod.png) and [mire_pendant.png](/mnt/project-files/pass-201/mire_pendant.png).
- A new game's abilities carry `pendant` and `magical_rod`, set to false.
- Bible 5.2: "The original's relics", a table of where each lies and what it does, with the Pendant's deviation. Bible 15.3: the Faithfulness row names its test. `levels/README.md`: the two props.

## Tests

- `test_economy.gd`, `test_the_faithfulness_checklist_is_all_here` (new) checks:
  - each of the original's eight towns has a Guru;
  - the sixteen ranks, in order;
  - the four rings, each a guardian's;
  - the four card keys, the doors that need them, and the one Joker Key;
  - the three springs and their rooms;
  - one arena each for the eight original guardians and the Evil One;
  - the five spells;
  - the Mattock, Wing Boots, Black Onyx, Hour Glass, Pendant and Magical Rod.
- `test_economy.gd`, `test_the_pendant_and_the_magical_rod` (new) checks where each lies, that touching one takes it for good, the Pendant's 1.1 on the blade, and the Rod's 18 on Deluge.
- `test_reachability.gd`, `test_the_pendant_and_the_rod_can_be_reached` (new): with the Mist's abilities the checker reaches both. The pickup sweep doesn't read `prop:` finds, so this checks them directly.

Full suite: 3913 of 3913 checks passed, with no script errors.

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
| Faithfulness | 5 | 99 | Unchanged score: the original's last two finds are in, and the rubric's checklist is held by one test. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 202 takes Combat (last pass 194, now the oldest).
