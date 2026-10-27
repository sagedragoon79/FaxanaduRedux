# Pass 163: every boss names its opening, and Executioner

Pass 162 left Bosses, Systems, Audio, Stability and Faithfulness tied at 98.5. Bosses and Systems weigh 10. Bosses' last pass (104) was the oldest, so pass 163 takes Bosses. I audited the bosses against bible 8 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| Arena reveals, phases, phase markers | every boss has 2 or 3 `PHASES` marks; `BossArena._track_phases` breaks on each one | fine |
| Telegraphs | every boss clamps its tells to `Enemy.MIN_TELEGRAPH` (`tell()`); the boss tests cover them | fine |
| The boss rush | it mends a third between fights and keeps its records (passes 156 to 158) | fine |
| Flashes (pass 161) | Borabohra, Pakukame, Ripasheiku, the Drowned Warden and King Grieve now wash their silhouettes | fine |
| **Stagger windows** | Bible 8 gives every boss a stagger window, and each fight has one: a stuck drill, a grounded roc, open jaws, a bound heart. But the game knew them only one boss at a time. The skills that reward a window (Bloodletting, and Executioner in bible 9) read only a parry stagger, which most bosses never take. Executioner, the Blade skill made for bosses, was not built. | **built** |

## As built

- **`Enemy.punishable()`:** the foe's opening, while blows land in full. By default it is a parry stagger. Each boss overrides it with its own window: Rokusutahn's cracked plates, Zoradohna's stuck drill, Ripasheiku fallen from the vault, Pakukame's open jaws, Borabohra grounded, the Foreman stunned, King Grieve reeling or fallen, the Drowned Warden staggered or exposed, the Evil One reeling (phase 1) or bound by the root (phase 3). For a boss of pieces, `BossSegment.punishable()` asks the boss, and Zorugeriru answers per head (`segment_punishable`: a head lying where it bit). Shadow Eura keeps the default parry stagger, and the core has no opening because no blade reaches it.
- **Executioner** is the Blade branch's ninth node, after Thrust, for 3 points. Melee blows on a boss in its opening land for 35% more (`combat_tuning.executioner_mult`). A common foe gets nothing more, nor does a boss on its guard.
- **Bloodletting** heals on the same openings, so it works in boss fights too.
- The tree now costs 49 points against the 29 the game gives, so Executioner is a real choice at the end of the Blade branch.

## Screenshots

- `/mnt/project-files/pass-163/skills-executioner.png`: the skill menu's Blade branch (Executioner sits below Thrust; the list scrolls).

## Tests

- `test_economy.gd`, `test_executioner_strikes_harder_into_a_bosss_opening` (new). It checks:
  - the node's cost and place in the tree, and the 1.35 multiplier;
  - a staggered common foe takes a plain cut;
  - a boss in its opening takes 35% more, and Bloodletting heals on it;
  - a boss on its guard takes a plain cut;
  - every boss script names its opening.
- `test_boss.gd`, `test_pakukame_shell_turns_blows_until_the_jaws_hang_open` now checks that the shut head is no opening and that the open jaws are one, through the head's hitbox.

Full suite: 3093 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.75 | Unchanged. |
| Combat and enemies | 15 | 98.75 | Unchanged. |
| World and level design | 15 | 98.75 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.75 | Every boss's stagger window is named in one place and rewarded by the tree: Executioner is built, and Bloodletting works in boss fights. |
| Systems | 10 | 98.5 | Unchanged. |
| Audio | 5 | 98.5 | Unchanged. |
| Stability and performance | 5 | 98.5 | Unchanged. |
| Faithfulness | 5 | 98.5 | Unchanged. |

Weighted score: 96.5875 (up from 96.5625). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Systems, Audio, Stability and Faithfulness are tied at 98.5. Systems weighs the most (10), so pass 164 takes Systems.
