# Pass 141: the Tree blooms

World (97.75, weight 15) was tied for lowest apart from Art with Systems, Audio, Stability and Faithfulness, and weighs the most of them. I audited the world against bible 3, 4 and 11 and the newest content.

| Check | Finding | Verdict |
| --- | --- | --- |
| 4.1 abilities and 4.2 critical path | All built; the game is finishable end to end | fine |
| 4.4 world-state changes, spring by spring and boss by boss | Each row is built and tested, from the sap hardening to Dartmoor draining | fine |
| 11 secrets | Hidden rooms in every large zone (pass 131), cracked-stone caches (pass 135), Meteor Shards (pass 140) | fine |
| **4.4, last row: "Evil One defeated"** | "Post-game: Tree blooms, palette shift to spring colors, all enemies respawn as remnants." None of it was built. After the ending, a cleared save went back to a world exactly as it was with the Evil One alive: the same meteor dust over Dartmoor, the same spores in Zenis, and every person still talking about the danger ahead. The game's last world change, the one the story builds to ("The Tree blooms again", bible 2), never happened in the world itself. | **built** |

## As built

On a save with the `cleared` flag (set by `GameState.begin_ending`):
- **Blossom:** a second `Motes` layer (`World.blossom`, reading `Motes.blossom_table()`) drifts pink petals down through Eolis, the Trunk, the Tower, the Mist, the Branches and Daybreak. There are 40 at a time, each two pixels long, turning end over end as they sway, and over half of them carry a lighter pixel. Dartmoor (the drowned city) and Zenis (the dead meteor) don't bloom.
- **The meteor's air settles:** `Motes.SETTLES` is now keyed by any flag. With `cleared`, Dartmoor's crystal dust thins to 35% and Zenis's spores to 20%, in the way Daybreak's rain already thinned to a drizzle with `spring:sky`.
- **People:** `Npc.lines(info, key)` returns `lines_cleared` once the Tree blooms, wherever it is written. Sixteen people have it: everyone a cleared save can meet who talks rather than trades.
  - The King marvels at the flowering, and the Gate Watch notes that the beasts were always the Tree's own.
  - Old Wena fishes petals out of the fountain, and the piper has a new tune with no name.
  - Hesk smells honey down Apolune's well-shaft, and Orrin will dig honest stone again.
  - The Forepaw elder mourns Grieve as a king. Tamsin can't stay out of the sun, and Okko points you to the smith with your Meteor Shards (pass 140).
  - Elder Aelwen sees flowers on the crown-leaf where the Devouring Bloom was. The warden still watches, and the weaver spins petal-silk.
  - Daybreak's bells ring on their own, and the mayor will cast you one.
  - Dartmoor's steward buried the king on his dais, and the mason chips grey crystal out of dry walls.
- `--say=NPC` in `game.gd` uses `Npc.lines`, so a screenshot with `--flags=cleared` shows the new lines.

**Left out, on purpose (bible 4.4 notes both):**
- **The palette shift to spring colors** is a color grade over every tileset and backdrop. That is art polish, which Sean deferred, so it waits for that phase.
- **"Remnant" enemies:** foes already return when you re-enter a room, and the post-game lines make the point that they were always the Tree's own creatures, not the meteor's. A separate remnant variant would add little.

## Screenshots

In `/mnt/project-files/pass-141/`:
- `plaza_bloom.png`: the Eolis plaza after the ending, with small pink petals drifting over the town, the full fountain, Old Wena and the piper.
- `king_bloom.png`: the King, after the ending: "The Tree is in flower, wanderer. From the roots to the crown, every bough at once. No one alive has seen it."

## Tests

`test_world.gd`:
- `test_the_tree_blooms_once_the_evil_one_is_dead`:
  - before the end, Eolis has its dust and no blossom;
  - after it, the Trunk has a full blossom layer;
  - every living zone is in the blossom table, and Dartmoor and Zenis aren't;
  - Zenis has no petals and its spores have settled to 20%.
- `test_the_town_speaks_of_the_blooming_tree`:
  - every talker a cleared save can meet has `lines_cleared`;
  - the King's lines switch at the flag, from both `lines` and `lines_after`.

The existing dialog-length test reads every key containing "lines", so it also checks that each new line fits the dialog box.

Full suite: 2597 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98 | Unchanged. |
| Combat and enemies | 15 | 98 | Unchanged. |
| World and level design | 15 | 98 | The last world-state change in 4.4 is built: after the ending, the world itself shows the Tree blooming and the meteor gone. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 97.75 | Unchanged. |
| Audio | 5 | 97.75 | Unchanged. |
| Stability and performance | 5 | 97.75 | Unchanged. |
| Faithfulness | 5 | 97.75 | Unchanged. |

Weighted score: 96.0 (up from 95.9625). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Systems, Audio, Stability and Faithfulness are tied at 97.75. Systems weighs the most (10), so pass 142 takes Systems.
