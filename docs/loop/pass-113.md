# Pass 113: the Guru Trials

Systems (95.75) was the lowest category apart from Art. Three planned systems were still unbuilt:
- The **boss rush**: the bible ties it to 100% completion, as an end-game reward.
- **Cloak dyes**: six, purely visual. They are a gold sink and the Trials' cosmetic prize.
- The **Guru Trials**: six optional platforming courses in Eolis, opened as the springs are restored. Each pays a Mantra Shard (and so skill points) plus a cosmetic.

The Trials carry the most weight:
- They tie into progression (the springs, Mantra Shards, skill points).
- They test the core of the game, which is movement.
- They give replay value through best times.
- The dyes need them first, because the Trials are where the dyes come from.

This pass builds the Trials system whole and the first two trials.

## As built

**Opening a trial.**
- The Guru in the Temple of Mantras gets a new "Guru Trials" row, showing trials cleared out of trials built.
- Until a spring flows, the row is dry ("The mantra-space is dry. Restore a spring and the Guru will open it.").
- The trial list shows each built trial in one of three ways: **Sealed** (with how many springs it needs), **Open**, or your **best time**.
- Trials open two by two, one pair per spring restored (`Trials.LIST`). A trial whose room isn't built yet isn't offered.

**The run.**
- Choosing a trial carries you to its start, and the clock starts at once.
- The HUD shows the trial's name, the clock and your best (or "FIRST WALK") at top center, drawn with `PixelFont`.
- **A hazard costs time, never health.** It sets you back on your last footing with a hurt flash and a soft hurt sound, and the clock runs on.
- The pause menu gains **"Leave the trial"**, which stops the clock and takes you back to the Guru, uncleared. Quitting the game also ends the run.

**The bell** (`prop: x, y, trial_goal`, the `TrialGoal` class) sits at the far end. It is a pale bell in a stone frame with a slow glow. Touching it:
1. rings the bell, with a flash;
2. shows your time, and says whether it is a new best;
3. keeps the best time in `GameState.data.trials` (trial id to seconds);
4. on the first clear, rings out a Mantra Shard (three make a skill point, bible 10);
5. after 1.2 s, carries you back to where you stood by the Guru.

**Saving.** Best times live in the save. `GameState.sanitize` drops any time that isn't a finite number of zero or more.

**The mantra-space** (`levels/trials/`, zone `trials`):
- It is off the map and out of the completion count (`World.OFF_MAP`, shared with the gym).
- It has its own tileset, parallax, decor, motes and glow:
  - pale grey masonry with no moss or warmth;
  - a void with great faint broken mantra rings behind, and pale slabs hanging nearer;
  - stone rubble, chains and a cold sconce for decor;
  - pale flecks hanging almost still in the air.

**The first two trials**, both open after the first spring:
- **Mantra of Walls** (40x30): three pillars over a spiked floor, thorned on their far sides, with thorn bulbs hanging in the gaps. You climb each with the Climbing Glove from the nub at its foot. From the last one, a drop takes you to the bell's ledge.
- **Mantra of Edges** (96x20): 1- and 2-wide pillars four tiles apart at changing heights over spikes. Then come four slats under a low ceiling that allows only short hops, and three rising pillars to the bell.

Still to come: Thorns and Winds (two springs), Stillness and Falling (three springs), and the cloak dyes that are the Trials' cosmetic prize.

**Debug flags:**
- `--open=trials` opens the trial menu.
- `--trial=ID[,SECONDS]` runs a trial's clock (for screenshots).

## Screenshots

In `/mnt/project-files/pass-113/`:
- `menu.png`: the Guru Trials menu in the temple, both trials open.
- `walls.png`: the Mantra of Walls, with the HUD clock.
- `edges.png`: on the slats under the low ceiling.
- `bell.png`: the bell on its ledge. The first draft's dark frame vanished against the void, so the frame now has pale posts with a dark outline.

## Tests

- `test_reachability.gd`: `test_every_guru_trial_can_be_cleared_with_the_glove`. For each built trial, the bell is reachable from the start with the glove alone, and no reachable spot is cut off from it. The trial rooms are left out of the door-based world checks because the Guru is their only way in.
- `test_systems.gd`:
  - `test_guru_trials_open_as_the_springs_flow`: sealed with no spring, the first pair opens with one, the next pair with two; the time format.
  - `test_a_trial_runs_on_a_clock_and_the_bell_clears_it`: the full loop through a real `World`:
    - the Guru's start carries you to the trial's start;
    - the clock runs;
    - the bell clears the trial, gives a shard and keeps the time;
    - you return to the spot you left;
    - a slower second clear keeps the best and gives no second shard.
  - `test_in_a_trial_hazards_cost_time_not_health`: spikes take no health and set you back while the clock runs, and "Leave the trial" returns you uncleared.
  - `test_trial_times_are_saved_and_sanitized`, and the pass-100 round-trip test now sets a best time too.

## Bible

- Section 3 has a new as-built paragraph on the Guru Trials, under the zone table.
- `levels/README.md` lists the `trial_goal` prop.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96 | Unchanged. |
| Combat and enemies | 15 | 96 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 96.5 | The Guru Trials work end to end: menu, clock, bell, rewards, best times saved, a safe way out. Two of six courses are built. |
| Audio | 5 | 96 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Full suite: 2208 checks, all passing.

Weighted score: 94.8 (up from 94.725).

## Next

Movement, Combat and Audio are tied at 96 for lowest apart from Art. Pass 114 takes Combat and builds the next planned foe from bible 7, the Seed Bomber for the Branches.
