# Pass 109: saves and settings that can't break

Stability (95) was the lowest category apart from Art. The soaks already cover play, so this pass covers the files the game reads and writes: the save slots and `settings.cfg`.

## What was wrong

| Case | Before | Risk |
| --- | --- | --- |
| Empty, cut-off or non-JSON save | `load_game` refused it | OK. But Continue on the title called `_continue()` anyway, with a new game's empty `save_room`, so the world started in no room. |
| A save of the wrong shape (a list, a number) | refused | OK, the same Continue problem. |
| Wrong types inside a save (`abilities` a list, `gold` a word, `save_pos` a string) | copied straight in | A crash the first time the game read that key, possibly long after loading. |
| Bad entries inside lists (a pin of one number, a skill id that is a number) | kept | A crash in the map or the skills screen. |
| Negative or infinite numbers, zero health | kept | Odd states: negative gold, or dying at once. |
| A rest in a room this build doesn't have | `world.start` on a missing room | A crash. |
| The write itself (disk full, killed mid-write) | the file was opened for writing in place | A half-written save. With no backup, the run was lost. |
| `settings.cfg` with wrong types (`rumble=5`, `sound=[1]`, a key bound to a word) | `bool()` and `int()` on whatever was there | `int(Array)` and the like are runtime errors, so the game crashed at start. |

## The fix

**Writing** (`GameState.write_safely`, used for saves and settings):
1. The text goes to `<file>.tmp`.
2. It is read back, and must match exactly.
3. The old file becomes `<file>.bak`.
4. The temp file is renamed into place.

A write that fails at any step leaves the last good file as it was.

**Loading:**
- `load_game` tries the slot, then its `.bak`. If neither is a save, it returns false and leaves the game in play untouched.
- `has_save` counts a lone backup.
- `delete_save` removes the backup and temp file as well.

**Sanitizing** (`GameState.sanitize`). Whatever loads is rebuilt on `fresh()`:
- Every key is present, and each must have its default's type. Numbers convert, since JSON stores every number as a float. Anything else falls back to the default.
- Dictionaries merge key by key under the same rule, so a bad blade id falls back while a good armor id stays.
- Lists keep only well-formed entries: string skill and ring ids, and pins of `[room, x, y]`. Guru stops and the save point must be `[x, y]`, and the purse must be whole or empty.
- Numbers must be finite and non-negative. Max health, max MP and flasks never fall below a new game's.
- A file must be an object with a `save_room` to count as a save at all.
- Keys a newer build added are kept, so a downgrade doesn't throw them away.

**The title.**
- If Continue can't load anything, it starts a new journey with a toast ("The old journey could not be read. A new one begins.") instead of failing.
- If the save names a room this build lacks (`World.room_exists`), you wake at the new-game spot.

**Settings.**
- A damaged `settings.cfg` loads its `.bak`, then the defaults.
- Every option must be a number (or, for rumble, a bool) and is clamped into range, so a negative speed or a volume of 99 is pulled back.
- Only a positive integer keycode is bound.

## Tests

`test_systems.gd`:
- `test_a_damaged_save_is_refused_and_leaves_the_game_alone`: six bad files, each refused, and the game in play untouched:
  - empty;
  - cut off;
  - plain text;
  - a list;
  - a number;
  - an object that isn't a save.
- `test_wrong_types_in_a_save_fall_back_to_their_defaults`: every rule in the sanitizer, on one hand-broken save.
- `test_a_damaged_save_falls_back_to_its_backup`: covers the following:
  - the second save leaves a `.bak` and no `.tmp`;
  - a damaged slot loads the backup;
  - a lone backup counts as a save;
  - delete removes both.
- `test_a_failed_write_keeps_the_last_good_save`: a directory sits where the temp file goes, so the write fails. `save_game` returns false and the old file is byte for byte the same.
- `test_damaged_settings_fall_back_to_defaults_or_their_backup`: covers the following:
  - an unreadable file gives the defaults;
  - wrong types fall back and out-of-range values clamp;
  - only real keycodes are bound;
  - a damaged file loads its backup.
- `test_a_rest_in_a_missing_room_wakes_at_the_start`

The pass-100 round-trip test and the older-save test still pass unchanged: sanitizing keeps every well-formed field exactly.

Full suite: 2113 checks, all passing.

## Bible

- Section 15.3 has a new paragraph, "Saves and settings (pass 109)".
- The architecture note on saving points to it.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 95.5 | Unchanged. |
| Combat and enemies | 15 | 95.5 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 95.75 | Unchanged. |
| Audio | 5 | 95.5 | Unchanged. |
| Stability and performance | 5 | 96.5 | No save or settings file can crash the game, half-load it, or lose the last good copy; each case is tested. |
| Faithfulness | 5 | 96.25 | Unchanged. |

Weighted score: 94.525 (up from 94.45).

## Next

Combat (95.5) and Movement (95.5) are now the lowest apart from Art. Pass 110 takes Combat and builds the next planned foe from bible 7: the Bark Knight for the Branches. The Branches have only the Leaf Mantis of their own, so they are now the thinnest zone.
