# Pass 134: Mantra of Death

Combat (97.5, weight 15) was tied for the lowest category apart from Art, and weighs the most of the tied ones. I audited bible 4 and 5 against what is built.

| Check | Finding | Verdict |
| --- | --- | --- |
| Combat numbers (5.3) | all in `combat_tuning.gd` and asserted | fine |
| Telegraphs | every foe's tell is at least `Enemy.MIN_TELEGRAPH`, and the sound test hears each one | fine |
| Spells (4.1) | all five built; Death came in pass 132 | fine |
| **The Arcana tree (9)** | Mantra of Death, the branch's last node in the bible's list, was the one spell node still unbuilt. Pass 132 left it for later. Without it, Death at 40 MP of a base 60 is a once-a-flask panic button, and a player who invests in Arcana gets nothing for the late-game spell. | **built** |

## As built (bible 4.1, 9)

- **Mantra of Death** (`mantra_of_death`, 3 points, after Time Thief): the Death spell costs half its MP (`Player.MANTRA_OF_DEATH_MULT` 0.5).
  - It stacks after Thrift: 20 MP, or 17 with Thrift.
  - Other spells are unchanged.
- `Player.spell_cost(id)` is now the one place a cast's MP is worked out.
- The bible's "unlocks the Death spell" half is dropped, because the scroll already unlocks it. The menu line says it needs the scroll.
- The built tree now costs 41 points against the 29 the game gives.

## Screenshots

In `/mnt/project-files/pass-134/`:
- `death_cost_plain.png`: Death cast from a full flask. A third of the MP bar is left.
- `death_cost_mantra.png`: the same cast with Mantra of Death. Two thirds are left.

## Tests

`test_mantra_of_death_halves_the_death_spell` (`test_economy.gd`), new:
- it waits on Time Thief and costs 3 points;
- Death costs half after Thrift, and Deluge only gets Thrift;
- a real cast takes 17 MP;
- a respec puts Death back at 40.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 97.75 | Unchanged. |
| Combat and enemies | 15 | 97.75 | The Arcana branch now ends in a payoff for the late-game spell. |
| World and level design | 15 | 97.5 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.5 | Unchanged. |
| Audio | 5 | 97.5 | Unchanged. |
| Stability and performance | 5 | 97.5 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Full suite: 2507 checks, all passing, with no script errors in the log.

Weighted score: 95.7875 (up from 95.75). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

World, Systems, Audio and Stability are tied at 97.5. World weighs the most (15), so pass 135 takes World.
