# Pass 159: Dartmoor wakes

Faithfulness (98.25, weight 5) was the lowest category apart from Art. I audited the remake against the original Faxanadu: the rubric's checklist (towns, Gurus, ranks, rings, keys, springs, the original bosses, the Evil One), bible 1, 2, 10 and 11, and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Ranks, rings, keys, springs, bosses, Evil One | all 16 ranks named by the Guru, four rings, five card keys, three springs, every original boss and the three-form Evil One | fine |
| The King's 1,500 gold, bread, poison, Ointment, Elixir, the Hour Glass | as in the original | fine |
| Boss rush, damage numbers, Mantra of Thorns | additions the bible plans; nothing in them contradicts the original | fine |
| Eolis of Old, Victim, Mascon | the original's look, sound and towns | fine |
| **Towns: Dartmoor** | The original's last town has a Guru and a key shop before the climb to Zenis, and bible 10.2 names Dartmoor a key master's town. Built, it had only the steward and mason after King Grieve: no Guru, no shop, and slugs and a crystal dwarf still patrolling its market. Seven of the eight towns had a Guru; this was the one gap left on the rubric's checklist. | **built** |
| Pendant and Magical Rod | still left out on purpose (not in the bible) | fine |

## As built

- **`calm:` room header** (`Room._spawn_enemy`, `levels/README.md`): once the named world flag is set, the room spawns no foes. The town is woken.
- **The Drowned Market** (`calm: boss:king_grieve`): once King Grieve falls, its foes are gone. Three people stand on the market floor:
  - the mason;
  - a Guru (rest and save, skills, the Mantra Path), the last Guru before Zenis;
  - **Keymaster Sigrun**, a dwarf in a slate coat and cap, drawn by `castgen.py`. Her shop, "Sigrun's Locks", sells Jack, Queen, King and Ace keys, Ointment and Elixirs. The Joker Key is still found, not sold: it lies on the stall-plank above her.
- All eight of the original's towns now stand with a Guru and a shop.

## Screenshots

- `/mnt/project-files/pass-159/dartmoor-market-woken.png`: the woken market, with the Guru and Sigrun under the Joker Key's plank.
- `/mnt/project-files/pass-159/dartmoor-keymaster.png`: Sigrun's Locks.

## Tests

- `test_rooms.gd`, `test_dartmoor_wakes_with_a_guru_and_a_key_master` (new). It checks that:
  - under the flood the market has foes and no people;
  - after King Grieve it has no foes, and the Guru, Sigrun and the mason stand in it;
  - Sigrun sells all four buyable keys and never the Joker.

Full suite: 2935 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.5 | Unchanged. |
| Combat and enemies | 15 | 98.5 | Unchanged. |
| World and level design | 15 | 98.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.5 | Unchanged. |
| Audio | 5 | 98.5 | Unchanged. |
| Stability and performance | 5 | 98.5 | Unchanged. |
| Faithfulness | 5 | 98.5 | Dartmoor is the original's last town again, with a Guru and a key master before Zenis; all eight towns stand. |

Weighted score: 96.4375 (up from 96.425). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Every category apart from Art is now at 98.5. Movement weighs the most (20), so pass 160 takes Movement. Unbuilt: Guru Trials Winds, Stillness and Falling.
