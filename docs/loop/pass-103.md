# Pass 103: every boss fight timed, and no sound waits on the disk

Stability (94) was tied for lowest with Movement, apart from Art. This pass times every boss fight frame by frame, looks for hitches and their causes, and pins the result in a test.

## The audit

Each of the 13 boss rooms was loaded fresh and the fight was started. The player then mashed for 25 s while the boss was knocked down 20% every 5 s to push it through its phases. For every frame I recorded the physics and process time, the room's node count, and anything newly loaded from disk. The sprite-sheet cache was cleared before each room.

| Fight | Average | 99th percentile |
| --- | --- | --- |
| Rokusutahn (root_chamber) | 0.59 ms | 1.36 ms |
| Foreman (foreman_hall) | 0.57 ms | 0.99 ms |
| Zoradohna (forepaw_lift) | 0.62 ms | 1.21 ms |
| Ripasheiku (sunken_chapel) | 0.60 ms | 1.16 ms |
| Zorugeriru (spring_of_mist) | 1.18 ms | 2.31 ms |
| Pakukame (crown_leaf) | 0.77 ms | 1.42 ms |
| Borabohra (roost) | 0.74 ms | 1.45 ms |
| King Grieve (throne_hall) | 0.69 ms | 1.25 ms |
| Shadow Eura (zenis_gate) | 0.53 ms | 1.12 ms |
| Evil Avatar (throne) | 0.53 ms | 0.79 ms |
| Evil Core (veins) | 0.46 ms | 0.84 ms |
| Evil Heart (heart) | 0.46 ms | 1.00 ms |
| Drowned Warden (wellspring) | 0.66 ms | 1.27 ms |

Headless timing is from the test container; real frames add rendering on top. Nodes never grew by more than 15 over a fight.

**Spikes.** One run showed a single 26 ms frame in the Wellspring and an 11.6 ms frame in the Crown Leaf. Neither came back in two reruns. Other one-off frames of 5 to 11 ms appeared in different fights each run. None of these frames loaded anything or added any node, so they are scheduler noise in the container, not the game.

**The real finding: sounds loaded mid-fight.** `Sfx` loaded each sound from disk the first time it played. With a fresh cache, every fight loaded 9 to 15 sounds after it had begun: the first slash, hit, hurt, landing, and the `phase_break` stinger right as a phase breaks. Each load cost about 0.3 to 0.6 ms here, on a fast disk with the files cached. On a laptop reading from a cold disk it can take far longer, which is the same kind of hitch pass 99 found with a boss's sprite sheet. Sprite sheets were clean: `BossArena.warm` already covers them.

## The fix

`Sfx.load_all()` runs in `Sfx._ready` and loads every sound in `assets/sfx/` once, at start. That is 82 files, about 2.2 MB and some 20 ms. In an exported game it also reads the `.import` and `.remap` names. A new counter, `Sfx.loads`, counts disk loads, so a test can prove none happen mid-play.

## Tests

`test_soak.gd`: `test_every_boss_fight_holds_the_frame_budget`
- Every sound is loaded with the game.
- All 13 fights run for 15 s each, with the same mashing and phase pushes as the audit.
- In each fight:
  - the average frame stays under 8 ms;
  - the 99th percentile stays under 16.6 ms;
  - no sprite sheet or sound loads after the fight starts;
  - nodes don't pile up.
- The 99th percentile is checked rather than the single worst frame, because the worst frame is noise on a shared machine.
- The whole test runs in about 12 s.
- **Checked by breaking it:** with `load_all()` switched off, the test fails and names every fight that loaded sounds (for example "root_chamber: loaded 11 sounds mid-fight").

Full suite: 1949 checks, all passing.

## Bible

Section 15.3's stability measures now describe the sound preload and the boss frame-budget test.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 94 | Unchanged. |
| Combat and enemies | 15 | 94.25 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.25 | Unchanged. |
| Systems | 10 | 94.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 95 | Every fight is timed and pinned by a test, and the last mid-play disk loads (sounds) are gone. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 93.84 (up from 93.79; 93.8375 unrounded).

## Next

Movement (94) is now the lowest apart from Art. Pass 104 audits it against the juice checklist in bible 6.7: every item checked in scripted runs and screenshots, and anything thin built out.
