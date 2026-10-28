# Pass 217: King Grieve's swallowed sword

Faithfulness's last pass (209) was the oldest apart from Art, so pass 217 takes Faithfulness. I audited the original's story beats, items and bosses against the bible and passes 210 to 216, checking claims about the original against StrategyWiki's Faxanadu enemy and boss pages and Wikipedia's plot summary.

| Check | Finding | Verdict |
| --- | --- | --- |
| Passes 210 to 216 | Hit-stops, a guardian's health, moved pickups, supplied music, engine errors and the Stride's veil. None touched the original's names, towns, items or story. | fine |
| Checklist (201, 209) | Towns, Gurus, ranks, rings, keys, springs, bosses, spells, relics and the towns' shops all pass. | fine |
| The King's 1,500 gold, the Gurus' mantras, the meteor and the Evil One | Wikipedia's plot summary matches the bible's story (2) and the built game. | fine |
| **The Dragon Slayer** | Wikipedia's summary says only the sword King Grieve swallowed can destroy the Evil One. StrategyWiki says beating Grieve releases the Dragon Slayer. In the remake it lay on an altar in Zenis's Heart Gate, and Grieve gave only the Demon Ring. One of the original's best-known story beats was missing. | **fixed: Grieve gives it up** |

## As built

- `BossArena.BOSSES.king_grieve` gains `"blade": "dragon_slayer"`. Beating him puts the sword straight into your hand (ability, gear and blade), alongside the Demon Ring and his skill point, with the banner "Dragon Slayer".
- The Heart Gate's altar (40,10) is bare. A sign on it reads: "An empty altar, cut to hold a sword. King Grieve swallowed the blade and took it down into Dartmoor." Screenshot: `/mnt/project-files/pass-217/heart_gate_altar.png`.
- `GameState.sanitize`: an old save that beat Grieve but never took the sword from the altar now gets it in hand, so it can still cut the heart's flesh.
- Reachability is unchanged. The throne already lay past both Grieve and the flesh, and the sweeps grant the Dragon Slayer as an ability.
- Tests:
  - `test_king_grieve_defeat_gives_the_demon_ring_and_the_dragon_slayer` (renamed and extended);
  - `test_a_save_past_king_grieve_holds_the_dragon_slayer` (new);
  - the faithfulness checklist (Grieve gives the sword, and no room lays legend `&`);
  - `test_the_dragon_slayer_cuts_the_flesh_of_the_heart`, which now checks that the altar is bare.
- Mutation check: with the reward's `blade` removed, the Grieve test fails 4 checks. With the save migration removed, the save test fails.
- Bible: A10, the critical path (4.2), the 5.2 tier table, 8.7 (reward, plus a "swallowed sword" note), the Heart Gate as built, and the 15.3 Faithfulness row. The `&` row in `levels/README.md` is updated too.

Full suite: 4061 of 4061 checks passed, with no script errors.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 99 | Unchanged. |
| Combat and enemies | 15 | 99 | Unchanged. |
| World and level design | 15 | 99 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 99 | Unchanged. |
| Systems | 10 | 99 | Unchanged. |
| Audio | 5 | 99 | Unchanged. |
| Stability and performance | 5 | 99 | Unchanged. |
| Faithfulness | 5 | 99 | Unchanged score: King Grieve's fight now carries the original's sword. |

Weighted score: 96.8625 (unchanged). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Pass 218 takes Combat (last pass 210, now the oldest).
