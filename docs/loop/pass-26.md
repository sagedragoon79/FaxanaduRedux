# Pass 26: The Mantra Path and the Deep Workings

Fast travel (design bible 3.3), a forge set piece for Forepaw, and four more Tower rooms. Faithfulness was 69, Stability 70,
Audio 70 and Art 73 going in.

## What changed

- **The Mantra Path** (bible 3.3). Guru-to-Guru travel.
  - Speaking to any Guru records a stop (`GameState.data.gurus`, room id to position; `meet_guru()`).
  - The Guru's menu has a new **Mantra Path** row. Before a spring flows it is shown dry ("Restore a spring to walk it"),
    so players learn it exists; after (`GameState.mantra_path_open()`, any `spring:` flag) it lists every other Guru met
    (`mantra_stops()`), by room name and zone.
  - Choosing one fades you (`World.travel`) to a step beside that Guru (`Menus.MANTRA_STEP`).
  - Old saves gain the key through the usual fresh-data merge.
- **The Forepaw forge** (`Forge`, room prop `forge`, beside Hrothgar). A brick hearth under a riveted iron hood and flue,
  coals and flames that breathe with a pumping bellows, an additive glow, embers up the flue, and an anvil whose billet
  cools between strikes. The smith rings it every 1.6 s: a shower of sparks and a new `anvil` sound, heard only nearby and
  quieter with distance. Drawn at 2x density. The elder moved a few steps east to make room.
- **Forepaw Deep Workings**, east of the town (Mattock rooms, 16 of 26 Tower rooms):
  - **Mine Mouth** (22,-4): an Iron Dwarf and a Monodron on the floor, a chest on a ledge, a platform climb to a ceiling shaft.
  - **Mine Shaft** (22,-6, two screens): a climb under Gear Bats and a Grub Lump, a chest, and a **Mantra Shard** behind
    cracked stone.
  - **Rail Gallery** (23,-6, two screens wide): the ore road, two spike pits (the long one is a pogo or a platform), two Iron
    Dwarves, a Potion Shard up on a pillar route, and the rails running east into the fog toward the Mist.
  - **Mine Vault** (24,-5): dropped into from the gallery; a Meditation Shrine, a Life Fruit on a ledge, and a climb back out.
- **Bible:** 3.3 (how the Mantra Path works) and 4.4 (forge and Deep Workings).

## Tests

- `test_the_mantra_path_joins_the_gurus_after_a_spring`: speaking marks a stop; the row is offered but dry; a spring opens it;
  it lists Apolune; choosing it lands you in Apolune on open floor a step from the Guru.
- `test_the_forepaw_forge_rings_and_throws_sparks`: the forge is there, the hammer rings on its timer, a strike throws sparks
  and they die away.
- The reach checker proves the four rooms with the Mattock set (they are in `MATTOCK_ROOMS`), and the tower soak now runs in
  them too.
- Found by the checker: a ceiling shaft one row too close to the platform under it (the body did not fit), a shaft climb with
  gaps a little wide, and a pocket wall behind the cracked stone; all fixed. The boot test caught the shaft's floor door being
  door 1 (tests boot there); renumbered.

575 checks pass, and the log has no script errors.

## Screenshots reviewed

`/mnt/project-files/pass-26/`: `forge.png` (the forge between Hrothgar and the elder), `mine_mouth.png`, `mine_shaft.png`,
`rail_gallery.png`, `mine_vault.png`.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 88 | Unchanged. |
| Combat and enemies | 15 | 81 | Unchanged. |
| World and level design | 15 | 80 | Four rooms, a vault loop, and the ore road pointing at the Mist. |
| Art cohesion | 15 | 74 | The forge gives Forepaw a warm focal point. |
| Bosses | 10 | 78 | Unchanged. |
| Systems | 10 | 77 | Fast travel. |
| Audio | 5 | 71 | The anvil. |
| Stability and performance | 5 | 70 | Soak covers the new rooms. |
| Faithfulness | 5 | 70 | The Mantra Path. |

Weighted score: 79 (78.90, up from 77.95).

## Lowest categories and next pass

1. **Faithfulness (70)** and **Stability (70)**: the Minecart Rider (the Tower's last listed enemy) and a save/load soak
   across the new systems (Mantra Path stops, tempers, lift).
2. **Art (74)**: Tower landmark rooms (the bible wants 3 per zone), and more Tower rooms toward 26.
