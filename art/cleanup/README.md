# art/cleanup — Sean's hand-cleaned PixelLab frames

Frames here override the raw PixelLab output. A clip folder under this directory, at the **same
relative path** it has under `art/pixellab/`, wins over the raw frames: the importer
(`tools/art/pixellab_sheets.py`, `frames_of`) returns the cleaned frames when they exist and
packs them **as-is**, with no slab or flat cleaning.

Use it for frames an automated pass must not touch — turn clips most of all, where PixelLab leaves
drift that Sean cleans by hand (enemy style guide, step 1b).

Rules for automated passes:

- Copy a turn clip's frames to `art/cleanup/<character>/turn/` (`00.png`, `01.png`, ...) and list
  them on the workbench under "done" as ready for Sean's cleanup.
- **Never overwrite or regenerate anything already here.** These are Sean's edits.
