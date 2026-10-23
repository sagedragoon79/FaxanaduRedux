# Pass 23: The Guru names your title

The lowest categories going in were Faithfulness (62) and Audio (66).

## What changed

- **The title ceremony, from Faxanadu.** Ranks still rise in the field the moment you pass a threshold, and the skill point arrives right away. The rank-up banner now says "Seek a Guru to be named and taught."
  - The next time you talk to a Guru, they name you by your new title before the usual menu opens.
  - The ceremony is three lines in the original's manner: praise, "From this day you shall be called ADEPT.", and a farewell.
  - Higher ranks hear grander words, in four tiers.
  - The ceremony happens once per new title. If you rank up twice between visits, you are named by the latest title.
  - `GameState.data.named_rank`, `unnamed_title()`, `name_title()`; `Npc.title_lines()`.
  - Old saves have no `named_rank`. It counts as 0, so their first Guru visit names them.
- **A title fanfare** (`assets/sfx/title.wav`, from `sfxgen.py`): a 2-second heraldic jingle, with a square lead over a triangle bass, ending on a held major chord.
  - It is appended at the end of the generator, so no other sound changed.
  - `Music.duck(time)` dips the music under it and brings it back.
- Screenshot options: `--xp=N`, and `--open=title`, which has the nearest Guru hold the ceremony.
- The design bible (section 9) is updated.

## Tests

`test_the_guru_names_your_title_once` checks:
- a Novice gets no ceremony;
- ranks rise unnamed;
- the Guru's second line names the title;
- `named_rank` catches up;
- a second visit is silent;
- the higher-rank tiers differ.

509 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-23/title.png` shows the Eolis Guru temple at 320 XP. The Adept banner is up, and the Guru's first line is in the dialog box.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 80 | Unchanged. |
| World and level design | 15 | 77 | Unchanged. |
| Art cohesion | 15 | 73 | Unchanged. |
| Bosses | 10 | 72 | Unchanged. |
| Systems | 10 | 74 | Unchanged. |
| Audio | 5 | 67 | A title fanfare, with the music ducking under it. |
| Stability and performance | 5 | 70 | Unchanged. |
| Faithfulness | 5 | 65 | The Guru's naming ceremony with the original 16 titles. |

Weighted score: 77 (76.80, up from 76.60).

## Lowest categories and next pass

1. **Bosses (72)**: Zoradohna, the Hammer of Forepaw (bible 8.2), beyond the Forepaw Gate. It is the
   biggest remaining gap in M4, and once it lands its sheet spec goes to the art thread for an HD pass.
2. **Faithfulness (65)** and **Audio (67)**.
3. **Art (73)**.
