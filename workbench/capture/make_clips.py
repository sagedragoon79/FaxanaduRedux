#!/usr/bin/env python3
"""Films short real clips of the game into workbench/clips as GIFs.

Usage: python3 workbench/capture/make_clips.py [--only=name,...]
  Needs GODOT set to a Godot 4.7.2 binary. Uses the game's own --film option, which
  saves every Nth frame of the window (HUD included, as the player sees it), then
  encodes the frames with Pillow at 15 fps, 640 wide. No ffmpeg needed.
"""
import glob, os, shutil, subprocess, sys, tempfile, time
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'workbench', 'clips')
GODOT = os.environ.get('GODOT', 'godot')
ONLY = set(next((a[7:] for a in sys.argv[1:] if a.startswith('--only=')), '').split(',')) - {''}
EVERY = 4          # 60 fps game time, every 4th frame: 15 fps
SECONDS = 10

# name -> game options. Each clip is real play driven by the game's own capture options.
CLIPS = {
    'title-screen': ['--title'],
    'heartwood-sword-combo': ['--room=heartwood/entrance', '--shot-move=1', '--shot-attack=10', '--ointments=3', '--use-ointment'],
    'gnarlmaw-fight': ['--room=heartwood/root_chamber', '--shot-at=20,19', '--shot-attack=14', '--ointments=3', '--use-ointment'],
    'haar-wyrm-fight': ['--room=haar/spring_of_haar', '--shot-attack=14', '--ointments=3', '--use-ointment', '--shot-at=%s'],
}


def film(name, args):
    frames = tempfile.mkdtemp(prefix='wbclip_')
    if '--shot-at=%s' in args:
        sys.path.insert(0, HERE)
        import capture_all as c
        rid = next(a[7:] for a in args if a.startswith('--room='))
        args = [a if a != '--shot-at=%s' else '--shot-at=%d,%d' % c.floor_mid(c.rooms()[rid]['grid']) for a in args]
    cmd = [GODOT, '--path', ROOT, '--position', '-8000,-8000', '--fixed-fps', '60', '--',
           '--film=' + frames.replace('\\', '/'), '--film-every=%d' % EVERY, '--shot-frames=%d' % (60 * SECONDS + 30)] + args
    t0 = time.time()
    subprocess.run(cmd, capture_output=True, timeout=600)
    files = sorted(glob.glob(os.path.join(frames, '*.png')))[30 // EVERY:]
    if not files:
        shutil.rmtree(frames, ignore_errors=True)
        return 'FAIL %s: no frames' % name
    imgs = []
    for f in files:
        im = Image.open(f).convert('RGB')
        im = im.resize((640, round(im.height * 640 / im.width)), Image.LANCZOS)
        imgs.append(im.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE))
    os.makedirs(OUT, exist_ok=True)
    out = os.path.join(OUT, name + '.gif')
    imgs[0].save(out, save_all=True, append_images=imgs[1:], duration=int(1000 * EVERY / 60), loop=0, optimize=True)
    shutil.rmtree(frames, ignore_errors=True)
    return 'ok   %s: %d frames, %.1f MB, %.0fs' % (name, len(imgs), os.path.getsize(out) / 1e6, time.time() - t0)


for name, args in CLIPS.items():
    if ONLY and name not in ONLY:
        continue
    print(film(name, list(args)), flush=True)
