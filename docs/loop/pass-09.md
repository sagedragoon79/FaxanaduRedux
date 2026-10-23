# Pass 09: pause menu, options and Ointment

Date: 2026-10-23. Scope: Systems (63). There was no pause menu and no way to change anything:
the bible's accessibility list (14) and its "settings all tested" rubric line were unmet, and
the Ointment from the item shop list (10.2) did not exist.

## What was built

- **Settings** (`scripts/data/settings.gd`, user://settings.cfg, apart from save slots): screen
  shake (full, half, off), screen flashes (full, reduced, off), rumble, music and sound volume
  (new Music and Sfx buses), and game speed (100 to 70%). Feel gained `flash_scale` and
  `game_speed`; slow motion and hit-stop return to the chosen speed rather than 100%.
- **Key rebinding:** choose an action, press its new key. A key taken from another action swaps
  with it, and one taken from another action's spare keys leaves that action. Reset to defaults.
  Esc cancels and always pauses.
- **Pause menu** (Esc or Start during play): Resume, Use Ointment, Options, Controls, Quit. The
  title menu gains Options and Controls. ListMenu now scrolls long lists, takes Left/Right for
  values, backs out of sub menus, and captures a key for rebinding.
- **Ointment:** 300 g in both item shops, carry three, rub one on from the pause menu for 10 s
  in which nothing hurts you. The player glows gold and flickers in the last 2 s; the HUD shows
  a jar, the count and a draining bar.

## Automated verification

362 checks pass (from 327; a new systems suite). Settings save and load, wrap and clamp, and
reach Feel and the buses; reduced flashes dim the boss-kill flash; game speed holds through
resets and scales slow motion; rebinding swaps, persists and resets; Ointments are bought up to
the cap, saved, used one at a time, block hits and wear off; the pause menu, Options, Controls
and Quit work through the real ListMenu. Screenshots reviewed: pause, options, controls (scrolled),
the shop with Ointment, the title menu, and the Ointment glow and HUD.

## Review against the bible

- 14 (accessibility): shake and flash toggles, game speed and keyboard remapping met; gamepad
  remapping waits for controller glyphs (noted in the bible).
- 10.2: the Ointment is in; the bible now records the carry cap and how it is used.
- 15.3 Systems row: settings are tested. Fast travel is still missing.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 70 | Unchanged. |
| World and level design | 15 | 58 | Unchanged. |
| Art cohesion | 15 | 65 | Unchanged. |
| Bosses | 10 | 68 | Unchanged. |
| Systems | 10 | 72 | Pause menu, options, rebinding, Ointment. No fast travel or inventory screen yet. |
| Audio | 5 | 62 | Separate music and sound volume. |
| Stability and performance | 5 | 60 | Unchanged. |
| Faithfulness | 5 | 54 | The Ointment, a Faxanadu staple. |

Weighted score: 69 (up from 68).

## Lowest categories and next pass

1. **World (58):** a third Trunk landmark, more rooms toward 28.
2. **Stability (60):** a soak run through every room, frame-time checks.
3. **Art (65):** props and tiles to the cast's standard, now that Autosprite is connected
   (a separate thread is taking the character animation).
