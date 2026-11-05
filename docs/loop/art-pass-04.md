# Art loop pass 4: the High Boughs foes

Batch 3 of the art loop: the Leaf Mantis, the Bark Knight, the Seed Bomber and the Mothling,
remade in PixelLab to the style guide (`docs/art/enemy-style-guide.md`) on the Shade Knight's
recipe: a `create-character-v3` side-view base, then pixminimax clips facing east, every clip
started from one pose so the model never drifts. No AI or numbers changed: art, sheets and
each foe's `_draw`.

## Before

- **Leaf Mantis** and **Mothling**: flat rectangles and polygons drawn in `_draw`.
- **Bark Knight** and **Seed Bomber**: castgen rig sheets, readable but coarser than the hero.

## After

| Foe | Height | Source | Animations | Generations |
|-----|--------|--------|------------|-------------|
| Leaf Mantis | 34 | 256 px base (5c38aea8); clips from its north-east view, its true side profile (`base/guard.png`; the base's east view faced the camera) | idle, stalk, hide (folded flat like a leaf cluster), unfold (reared, scythes up: the tell), lunge, recover (overreached, scythes low), hurt, stagger, death | 18 |
| Bark Knight | 36 | 256 px base (35317da8) with his lance laid in his hand (`base/guard.png`, from a PixelLab lance image); bare heartwood is a character state of him (1ca41b38) | idle, walk, brace (the tell), thrust, rooted (roots grow from his feet), hurt, stagger, death, each in bark and bare (`bare_`) | 51 |
| Seed Bomber | 26 | 128 px base (05c30138) | fly, windup (wings up, husk squeezed), drop, empty, fall (tumbling out of the sky), downed (on its back), hurt, stagger, death | 8 |
| Mothling | 18 | 128 px base (231a7a98) | fly (full wingbeat), windup (wings flared, screeching), dive (wings swept back), hurt, death | 9 |

88 generations in all (budget about 130), retakes included: the Mothling's first wingbeat barely
moved its wings; the bare knight's first thrust drifted to another model (red bark, a green glow),
because its subject description still named the bark armour; the Mantis's rear was retaken once.

### The Bark Knight's lance

His rooted lance is a ledge 72 px long at `LANCE_Y` (18 px up), and the art must sit on it. Two
choices follow:

- **Height 36**, so the lance he holds in the clips is 18 px up. That puts him in the guide's
  Standard class (his hitbox is 32), not Large, so the guide's scale table moves him.
- **The long lance** is drawn out from each frame's own pixels on a 640 px canvas
  (`tools/art/bark_lance.py`): one column of the clip's shaft repeated, then its thorn point, so
  it keeps the frame's colours and gets the importer's outline. The thrust's two frames reach 50
  and 72 px, the rooted frames 72. The guide gains a line on this.

The pale scars where his plates come off stay code, drawn over the sheet.

### Hookups

Each foe's `anim_now()` maps its states to the sheet: a flinch while in hitstun (but never over a
tell or a strike), the reel while staggered, and its collapse under the dissolve (it keeps
redrawing while it dissolves, as the Shade Knight does). The tell's white pulse stays code
(`telegraph_pulse`); the Mothling's tremble in its screech stays a code jitter. The Seed Bomber
tumbles while it falls and lies on its back once it lands.

`test_leaf_mantis_plays_an_animation_for_every_state`, `..._bark_knight_...in_bark_and_bare`,
`..._seed_bomber_...` and `..._mothling_...` hold every state to an animation its sheet has,
the tell to a pose of its own, and the hurt, stagger and death to theirs.

## Review notes

- The Mantis's reared tell turns partly toward the camera (both takes did). It reads as a rear
  and spreads the scythes clear of the body, so it stays; a third take is cheap if the lead wants it.
- The Mothling keeps the Bloom's violet and pink (it is Snapcrown's brood, not a canopy native).
- The Bark Knight in profile is narrow and dark: a gain of 1.2 and a sky-blue rim (0.35) lift him off the boughs (the lead review asked for a touch more).

Images: `/mnt/project-files/art-loop/<foe>/` (before and after lineups, every animation, the
foes in Thicket Road and Canopy Bridge) and `batch3-high-boughs-lineup.png`.
