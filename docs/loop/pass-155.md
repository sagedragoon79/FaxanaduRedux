# Pass 155: the Mantra of Thorns

World (98.25, weight 15) was tied for lowest apart from Art with Systems, Audio, Stability and Faithfulness, and weighs the most of them. I audited the world against bible 3, 4 and 11 and the newest rooms, and checked the pass-152 NES filter's pixel grid.

| Check | Finding | Verdict |
| --- | --- | --- |
| Eolis of Old (pass 152) | reachable through the temple's fake wall; a hidden room on the completion card | fine |
| **The NES filter's grid** | The world draws into a view at `GameCamera.DETAIL` (2) with a pixel of margin, 1284 x 724. The shader divided that height by 360 and drew blocks of 4.02 render pixels, so its blocks drifted across the world's pixels: in a screenshot 72% of colour edges fell off a 4-pixel grid. | **fixed** |
| Victim and Mascon (passes 145, 148) | soaked with the Mist; every door pairs | fine |
| 4.2 critical path | the soaks walk it end to end; the game is finishable | fine |
| **3.1 Guru Trials: six planned, two built** | Walls and Edges since pass 113. The second spring opened nothing new: the Guru listed Thorns and Winds only as unbuilt. The trials are the bible's mastery courses, and a Mantra Shard comes with each first clear. | **third built** |

## As built

- **NES filter:** the shader takes `detail` (render pixels per world pixel) from `RetroFilter.detail_for(viewport)`, which is 2 in the game's world view and 1 in a bare window. A block is `block * detail` render pixels, laid from the view's corner where the world's pixels start, and the 4:3 frame's edges sit on the same grid. In the new screenshot every colour edge falls on the 4-pixel grid, against 28% before.
- **`Trials.LIST` gains `needs`:** the abilities a course is built for (the Glove if not given). By its springs every one of them is in hand. `test_every_guru_trial_can_be_cleared_with_the_glove` now checks each trial with its own needs.
- **The Mantra of Thorns** (`levels/trials/thorns.room`, 96 x 20; Glove and Mattock; opened by the second spring):
  - a 20-tile spike corridor from the start ledge, to pogo along;
  - a pit under a chain of five thorn bulbs four tiles apart. The bulbs are the fast way; fall in and you pogo the spikes to the far wall and climb out;
  - two bulbs rising to a slab that hangs from the east wall over more spikes, with the bell on it. Nothing climbs to the slab, so the last two bulbs are the only way up.
  - The Guru's line: "Spikes, and thorns in the air. Strike down on every one; never touch the ground."

## Screenshots

- `/mnt/project-files/pass-155/thorns_pit.png`: the pit and its five bulbs.
- `/mnt/project-files/pass-155/thorns_stair.png`: the two bulbs up to the hanging slab.
- `/mnt/project-files/pass-155/old_eolis_aligned.png`: Eolis of Old with the blocks on the world's pixels.

## Tests

- `test_systems.gd`, `test_the_mantra_of_thorns_is_cleared_by_pogo` (new):
  - the trial is built with its needs and a description;
  - without the Mattock the checker can't reach the bell;
  - a simple pogo-playing hand clears it in the real game. It walks right, jumps off edges, steers over the next bulb and strikes down while falling. It rings the bell in about 12 s with nine pogos and three setbacks.
- `test_world.gd`, `test_the_nes_filter_blocks_on_world_pixels` (new): the detail is 2 in the game's world view and 1 with none.
- `test_reachability.gd`: every trial is checked with its own needs.

Full suite: 2815 checks, all passing, with no script errors in the log.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 98.5 | Unchanged. |
| Combat and enemies | 15 | 98.5 | Unchanged. |
| World and level design | 15 | 98.5 | A third Guru Trial, the pogo course the second spring was meant to open. The NES room's pixels are true. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 98.25 | Unchanged. |
| Audio | 5 | 98.25 | Unchanged. |
| Stability and performance | 5 | 98.25 | Unchanged. |
| Faithfulness | 5 | 98.25 | Unchanged. |

Weighted score: 96.375 (up from 96.3375). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Systems, Audio, Stability and Faithfulness are tied at 98.25, the lowest apart from Art. Systems weighs the most (10), so pass 156 takes Systems. Three trials remain unbuilt (Winds, Stillness, Falling), and the boss rush.
