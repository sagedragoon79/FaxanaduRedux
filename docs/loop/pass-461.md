# Pass 461: Yldenfall, an original world (the names)

Sean decided (2026-11-04) the game stops being a remake and becomes an original game with its own
story and names. This pass applies the names and the story to everything a player or a reader sees;
the internal ids (zone folders, room, item, flag and boss ids) follow in the next pass, with a save
migration.

- **Story:** bible sections 1 and 2 rewritten (the Ylden, the Everbloom, stillglass, Thane Vorrund,
  the stranger with the glass leaf). New lines for the Reeve, the Ringreader, the Amberlee miner, the
  Kettleforge elder, the Vorrhallow steward, Carillon's mayor and others; a new ending.
- **Names:** every retired name and its new one is in `data/rename_map.json`; the one-time rename
  script is `tools/rename/display_names.py`. Script classes named for retired names were renamed too
  (`Rokusutahn` is `Gnarlmaw`, `Naga` is `SiltAdder`, and so on); their files keep old names until
  the ids pass.
- **Rubric:** "Faithfulness" is retired; its 5 points go to **Story and world** (15.3). Removed
  `test_the_faithfulness_checklist_is_all_here`, the "whose is it" ledger and its test, and the old
  rename-list test. Added `test_no_retired_name_is_left` and `test_old_saves_come_over_to_the_new_name`
  (the game's user folder is now named Yldenfall; saves and settings are copied over on first start).

The scoring loop resumes with the next pass.
