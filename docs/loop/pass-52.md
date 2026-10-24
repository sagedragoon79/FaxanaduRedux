# Pass 52: Pakukame, the Devouring Bloom

The Branches' boss (bible 8.5), code-drawn at 2x. It tests the Elven Stride from pass 51.

## What changed

- **Pakukame** (`scripts/bosses/pakukame.gd`), rooted in the middle of the **Crown-Leaf** (`branches/crown_leaf`,
  47,-10, 60x23, east of the Windloft through its new door 2). The arena has pods at both ends and perches above them.
  - Only the head (a `BossSegment`) can be struck. The shell turns 70% of a blow. After a bite the jaws hang open on
    the leaf for 1.3 s and every blow lands in full.
  - **Bite** (within 110 px): rears back with its jaws parting for 0.55 s, then lunges at you for 24. Parrying it keeps
    the jaws open 0.9 s longer.
  - **Vine whip** (farther off): a vine coils at the root for 0.6 s, then lashes 170 px along the leaf for 16. It can't
    be parried; jump it or stride through it.
  - **Seed spit** (alternates with the whip): swells for 0.5 s, then spits three arcing seeds (`SeedShot`, 12 each,
    parryable).
  - **Phase 2** (below half): tells are a fifth shorter, never under 0.35 s. Every other bite tears a four-tile chunk
    out of the leaf with `Room.tear_floor`, leaving thorns below. At most three gaps, never next to the root or the
    walls.
  - Phase 3 (the uprooted chase) is deferred; bible 8.5 says so.
  - Reward: a skill point, 120 to 160 gold, and the banner "The Bloom Wilts".
- **Music:** `pakukame`, a lurching A phrygian fight at 140 with double "paku-paku" kicks and offbeat snapping bass.
- `--boss-hp` works for Pakukame.
- **Bible 8.5** is rewritten to the numbers as built: the arena, the body, all three attacks, phase 2, the look and
  the reward. The reward wording changed because the arena now sits past the Windloft.

## Tests

- `test_boss.gd`:
  - `test_crown_leaf_wakes_pakukame`: arena, music, head live, stem not hittable.
  - `test_pakukame_telegraphs_are_fair`: both phases.
  - `test_pakukame_shell_turns_blows_until_the_jaws_hang_open`: 3 of 10 through the shell, a fair bite tell, the bite
    lands, the head lies low, then 10 of 10 while open, then the head retracts.
  - `test_a_parried_bite_holds_the_jaws_open`.
  - `test_pakukame_whip_lashes_along_the_leaf`.
  - `test_pakukame_spits_seeds_in_arcs`.
  - `test_phase_two_bites_tear_the_leaf`: the gap opens where the jaws landed, the root's leaf stays, and thorns line
    the pit.
  - `test_pakukame_defeat_opens_the_crown_leaf`: flag, skill point, and the boss never returns.
  - The music list includes `pakukame`.
- `test_soak.gd`: `test_bloom_fight_soak_stays_lean`. A 30 s random-input fight with phase 2 forced halfway ran at
  0.52 ms a frame, 2.7 ms at worst. Effects don't pile up and the gap cap holds.
- `test_reachability.gd`: the Crown-Leaf is in `MATTOCK_ROOMS`.

## Screenshots

`/mnt/project-files/pass-52/`: `pakukame_idle.png` (the reveal banner and the Bloom on its leaf), `pakukame_bite.png`
(the bite tell's flash) and `pakukame_late.png` (below half, at `--boss-hp=0.4`).

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 90 | Unchanged. |
| Combat and enemies | 15 | 87 | Unchanged. |
| World and level design | 15 | 91.5 | Unchanged. |
| Art cohesion | 15 | 84 | Unchanged (on hold). |
| Bosses | 10 | 88.5 | The fifth original boss, with an ability test and an arena that changes. |
| Systems | 10 | 87 | Unchanged. |
| Audio | 5 | 87.5 | A boss theme. |
| Stability and performance | 5 | 85.5 | A boss fight soak. |
| Faithfulness | 5 | 88 | Unchanged. |

Weighted score: 87.98 (up from 87.78).

## Lowest categories and next pass

Leaving Art aside (on hold), the lowest is Stability (85.5), then Combat (87) and Systems (87). Next is a systems and
stability pass: an Act II save round trip that includes the Stride, Conflate and Pakukame, plus a look at the
skill tree's Act II nodes (bible 9), such as a second air-dash charge (6.5).
