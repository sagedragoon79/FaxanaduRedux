# Pass 237: the skill tree says what a skill waits on

Systems' last pass (229) was the oldest apart from Art, so pass 237 takes Systems. Pass 236 found a boss counter that assumed an ability the player didn't have yet, so I looked for the same thing across the systems: shops, NPC advice, toasts, the skill tree, the Guru, and the Equipment and Inventory pages.

| Check | Finding | Verdict |
| --- | --- | --- |
| NPC advice and toasts | Every line that names an ability (the Stride's shrine, the elven veil) is about where to find it, not a request to use it. | holds |
| Shops | Stock gated by `requires` flags, and every shelf sells a real item (pass 209). | holds |
| Save migration | `RENAMED_ITEMS` and `MOVED_PICKUPS` carry old saves (passes 213, 235). | holds |
| **The skill tree** | A branch deepens in order, not by what you have found, so nine skills can be learned before the ability or spell they work through: Mattock Mastery, Deluge Pierce, Tilte Swarm, Chain Thunder, Time Thief, Mantra of Death, Second Stride, Feather Fall and Wanderer's Grace. Only four of them said so, in their own words. Time Thief (before the Hour Glass) or Mattock Mastery (before the Foreman) spent a scarce point on nothing, without a word. | **fixed** |

## As built

- `data/skills.json`: each of the nine names what it uses (`"uses": "boots"`, and so on). The four hand-written "Needs the ..." notes are gone, replaced by one generated line.
- `Skills.waits_on(id)` names the ability a skill works through while it isn't found yet.
- `Menus.skill_rows()` builds the tree's rows, pulled out of `open_skills` so a test can read them. Until the ability is found, a waiting skill's line ends "Does nothing until you find the Wing Boots."
- The choice isn't blocked, because a point spent ahead still pays off later.
- `test_the_skill_tree_says_what_a_skill_waits_on` (`test_economy.gd`, new). It checks that:
  - every `uses` names a real ability;
  - no skill names an ability in its text without one;
  - nine skills wait on a new game and none do with everything found;
  - every line fits the menu's three lines.
- Mutation check: dropping Time Thief's `uses` fails the test, which names `time_thief: hourglass`.
- Screenshot: `/mnt/project-files/pass-237/skills.png`. Feather Fall's line reads "Needs Second Stride first. Does nothing until you find the Wing Boots." in three lines.
- Bible 9: "What a skill waits on".

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged score: the tree no longer lets a scarce point go to nothing without saying so. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged. |

Weighted score: 96.8625 (unchanged). Art (84.75, deferred by Sean) is still under the 85 floor.

## Next

Pass 238 takes Audio (last pass 230, now the oldest).
