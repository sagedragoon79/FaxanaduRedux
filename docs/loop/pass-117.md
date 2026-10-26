# Pass 117: the card doors

Faithfulness (96.25) was the lowest category apart from Art. I audited the remake against the original Faxanadu (bible sections 1 to 4) for items, doors, shops and towns:

| Thing | Before | Verdict |
| --- | --- | --- |
| Towns, Gurus, mantras, springs | all built, with their people and their lines | fine |
| Bosses and the ending | every boss through the Evil One, and the ending | fine |
| Spells, Wing Boots, Glove, Onyx, Hour Glass, Dragon Slayer | built | fine |
| Pendant, Magical Rod, Battle Helmet | not built | gaps, smaller |
| **Key doors** | the original's signature locks are five cards: Jack, Queen, King, Ace and Joker. Bible 3 lists all five and 10.1 prices four keys. Only the Jack existed, and there was one Jack door in the whole game. | **the gap** |

The card doors are the most visible of these. In the original you meet a Queen or King door long before you can open it and come back with the key, which is the remake's backtracking promise in its oldest form. The Pendant, Rod and Helmet are worth a later pass.

## As built

**Doors** (`KeyDoor`, legend `J`):
- A header line `lock: x, y, kind` turns the `J` on that tile into a Queen, King, Ace or Joker door.
- Each card wears its suit:

| Card | Panel | Bands | Suit |
| --- | --- | --- | --- |
| Jack | oak | iron | gold spade |
| Queen | red lacquer | gold | heart |
| King | blackened iron | gold | club |
| Ace | elf-silver | white | blue diamond |
| Joker | violet | green | gold star that winks |

- A door opens only to its own key and spends that key. Any other card's key does nothing, and the toast names the card you need.

**Vaults.** Card doors guard treasure, never the way on (bible 3). Each one closes a roofed pocket at the left wall with a chest worth more than its key. A new header line `chest: x, y, gold` sets one chest's gold, apart from the room's `chest_gold`.

| Door | Room | Chest | Key |
| --- | --- | --- | --- |
| Queen | Feather Hollow (Mist) | 900 g | 400 g at Apolune |
| King | North Bough (Branches) | 1,800 g | 900 g at Conflate |
| Ace | Spire Stair (Daybreak) | 3,200 g | 1,800 g at Daybreak |
| Joker | Meteor Rise (Dartmoor) | 5,000 g | found |

**Keys.**
- The Queen, King and Ace Keys are new items (`items.json`), each sold by the grocer a zone before its door, at the bible's prices.
- The one Joker Key is never sold. It lies on the stall-plank of the Drowned Market, laid by a new prop (`prop: x, y, joker_key`), and is taken once like any found item.
- The map's status line now lists the keys you hold ("Keys: Jack 1, Queen 1") instead of counting only Jack Keys.

## Screenshots

In `/mnt/project-files/pass-117/`:
- `queen.png`: the red Queen door with its heart in Feather Hollow, and the vault's chest behind it.
- `king.png`: the King door in the North Bough.
- `ace.png`: the elf-silver Ace door on the Spire Stair.
- `joker.png`: the violet Joker door with its star on the Meteor Rise.
- `jokerkey.png`: the Joker Key on its plank in the Drowned Market.

## Tests

In `test_economy.gd`:
- `test_card_doors_take_only_their_own_key`:
  - the `lock:` line makes a Queen door, and the `chest:` line sets that chest's gold;
  - Jack and King Keys don't open it and aren't spent;
  - the Queen Key opens it and only that key is spent;
  - the map lists the keys you hold;
  - every card has a look.
- `test_the_card_keys_are_sold_and_the_joker_is_found`:
  - each card key can be bought where it is sold, at 400, 900 and 1,800 g;
  - no one sells the Joker Key;
  - it lies in the Drowned Market;
  - the prop lays it, touching it gives it, and it never comes back.
- `test_every_card_door_guards_a_vault`: in each of the four rooms, the lock names a `J` of the right card, with a chest behind it and a roof over it.
- Reachability passes with the four vaults.

## Bible

- Section 3, Key doors: the as-built description, with where each vault is and where its key is sold.
- Section 10.1, Key master: the grocers sell the keys.
- `levels/README.md`: the `lock:` and `chest:` header lines, the `J` legend and the `joker_key` prop.

## Rubric

| Category | Weight | Score | Notes |
| --- | --- | --- | --- |
| Movement feel | 20 | 96.5 | Unchanged. |
| Combat and enemies | 15 | 96.5 | Unchanged. |
| World and level design | 15 | 97 | Unchanged. |
| Art cohesion | 15 | 84.75 | Unchanged (deferred). |
| Bosses | 10 | 98.5 | Unchanged. |
| Systems | 10 | 96.5 | Unchanged. |
| Audio | 5 | 96.5 | Unchanged. |
| Stability and performance | 5 | 96.5 | Unchanged. |
| Faithfulness | 5 | 96.75 | All five card doors of the original are in, each with its suit and its own key, and the Joker Key is found. The Pendant, Magical Rod and Battle Helmet are still missing. |

Full suite: 2305 checks, all passing.

Weighted score: 95.025 (up from 95.0). The loop's exit also needs every category at 85 or more, and Art (84.75, deferred by Sean) is still under it.

## Next

Movement, Combat, Systems, Audio and Stability are tied at 96.5. Pass 118 takes Systems, with the Pendant, Magical Rod and Battle Helmet as candidates where they touch the equipment system.
