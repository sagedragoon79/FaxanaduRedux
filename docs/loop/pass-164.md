# Pass 164: mantra dyes

Pass 163 left Systems, Audio, Stability and Faithfulness tied at 98.5. Systems weighs the most (10), so pass 164 takes Systems. I audited systems against bible 9 and 10 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Skill tree | Executioner (pass 163) is built. The tree costs 49 points against the 29 given, so every build makes choices. | fine |
| Shops and keys | Sigrun's Locks in the woken Drowned Market sells every key but the Joker (pass 159) | fine |
| Saves | the sanitizer keeps unknown dyes and skills harmless (pass 138); trials and rush records save | fine |
| Boss rush records | `trials["boss_rush"]` keeps the best time (pass 156) | fine |
| **Guru Trial rewards** | Bible 10's secrets table gives the trials "Cosmetics, a Mantra Shard each". The shard was built, but the cosmetics were not. A trial's best time was kept and shown, but it earned nothing, so there was no reason to run a trial again after the first clear. | **built** |
| **The trials list** | While adding the mantra line to the Guru's list, I found the row logic is an if/elif chain, so the new line has to come after it. The new test checks that a sealed trial stays "Sealed". | covered |

## As built

- Each built trial gets a **mantra time** and a **dye** in `Trials.LIST`:

  | Trial | Mantra time | Dye |
  | --- | --- | --- |
  | Walls | 12 s | Mantra Slate |
  | Edges | 14 s | Ledge Coral |
  | Thorns | 15 s | Thorn Rose |
  | Winds | 14 s | Wind Jade |
  | Stillness | 32 s | Still Frost |

- `Trials.finish()` returns the dye a run earned. A run within the mantra time that doesn't own the dye yet calls `GameState.earn_dye`. That owns the dye, puts it on the cloak, and sets `dye:<id>`.
- Ilse's Dyeworks keeps a place for each mantra dye: price 0, `requires` its flag. Once earned, you can wear it again there for nothing.
- The bell's toast says "Within the mantra: your cloak takes Thorn Rose."
- The Guru's list adds "Ring it within 0:14.0 for Ledge Coral." to each open trial, or "Within the mantra: Mantra Slate is yours."
- The mantra times come from each course's length and its waits. The Thorns pogo hand clears in about 12 s. Stillness needs about 29 s if you wait twice at the niche. They ask for a clean run, not a perfect one.

## Screenshots

- `/mnt/project-files/pass-164/ilse-mantra-dye.png`: Ilse's Dyeworks with an earned mantra dye on the shelf.

## Tests

- `test_systems.gd`, `test_a_trial_rung_within_its_mantra_dyes_the_cloak` (new). It checks that:
  - every built trial has a mantra time and a distinct colored dye;
  - the dye is off Ilse's shelf until earned;
  - a slow clear earns nothing;
  - a clear within the mantra owns and wears the dye and shelves it;
  - the sprite is recolored;
  - Ilse puts it back on for nothing;
  - a second quick clear gives nothing more;
  - the save keeps the dye;
  - the Guru's list names the dye as yours or names the mantra time, and keeps a sealed trial sealed.

Full suite: 3116 checks, all passing, with no script errors in the log. (The first run caught `test_the_dyer_dyes_the_cloak` reading the Lord's Gold as the last shelf entry; the mantra dyes now sit before it.)

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Unchanged. |
| Combat and enemies | 15 | 98.75 | Unchanged. |
| World and level design | 15 | 98.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Unchanged. |
| Systems | 10 | 98.75 | The trials' promised cosmetics are built: a best time now earns something, and Ilse keeps it. |
| Audio | 5 | 98.5 | Unchanged. |
| Stability and performance | 5 | 98.5 | Unchanged. |
| Faithfulness | 5 | 98.5 | Unchanged. |

Weighted score: 96.6125 (up from 96.5875). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Audio, Stability and Faithfulness are tied at 98.5 and weigh 5 each. Audio's last pass (157) is the oldest, so pass 165 takes Audio.
