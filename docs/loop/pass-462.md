# Pass 462: Yldenfall, the ids

Pass 461 renamed what the player and the bible see; this pass renames what only the code sees, as the
rename plan Sean approved (2026-11-04) said.

- **Ids and files:** zone folders (`eolis` is `hearthroot`, `trunk` is `heartwood`, `mist` is `haar`,
  `branches` is `boughs`, `daybreak` is `spires`, `dartmoor` is `vorrhallow`, `zenis` is `evercrown`),
  room, item, ability, npc, boss and flag ids, script files, music, sprites and the PixelLab and
  Autosprite source folders: about 2,800 files moved and 430 edited. The card keys are now metal keys
  in the code as well (`copper`, `silver`, `gold`, `thorn`, `glass`), and the seeds are `thaw`, `sun`,
  `fall` and `frost`. Plain English words (mist, trunk, guru, king) were renamed only where they are
  ids, never in prose; the role `king` (the Reeve's) and the spells Kindle, Stormcall and Wither
  (`fire`, `thunder`, `death`) keep their plain ids.
- **Saves:** the table is `ids` in `data/rename_map.json`. `tools/rename/ids.py` applied it to the
  repo, and `GameState.migrate_ids` applies the same table to a save older than version 3, so an old
  journey loads where it was. `test_an_old_save_comes_over_to_the_new_ids` loads an example old save
  kept in the table.
- **Guard:** `test_no_retired_name_is_left` also fails if a retired word that is not English is left in
  any id, file name or line, or a zone folder keeps an old name.

Left for later: the card suits drawn on the key doors (spade, heart, club, diamond, star) are the last
trace of the old card keys.

The scoring loop resumes with the next pass.
