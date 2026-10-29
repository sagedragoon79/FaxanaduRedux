#!/usr/bin/env python3
"""Measures the mix: peak and loudness of every sound effect and music track.

    python3 tools/audio/levels.py            # table and outliers
    python3 tools/audio/levels.py --check    # exit 1 if anything clips or strays

Loudness is the RMS of the audible part (samples above -50 dBFS), so a short
hit with a long quiet tail is not judged by its silence. Music is measured
from the file the game plays (a supplied .mp3 or .wav before the .ogg
placeholder), decoded with ffmpeg. A sound is an outlier when its loudness is more than
SPREAD dB from the median of its group, or its peak is at or over CLIP. A sound
effect must also keep HEADROOM dB inside the spread (pass 270): one sitting on
the edge failed the check whenever a new sound nudged the median. A cue that
must play louder is saved quieter and lifted in game (Sfx.LIFT).
"""
import subprocess
import sys
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
SFX = ROOT / "assets" / "sfx"
MUSIC = ROOT / "assets" / "music"
CLIP = -0.1
SPREAD = 9.0
HEADROOM = 1.5


def db(x):
    return 20 * np.log10(max(x, 1e-9))


def read_wav(path):
    with wave.open(str(path)) as w:
        data = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16)
        return data.astype(np.float64).reshape(-1, w.getnchannels()).mean(axis=1) / 32768.0


def played(paths):
    """The file each track plays from: a supplied .mp3 or .wav before the .ogg
    placeholder of the same name (Music.EXTENSIONS)."""
    order = {".mp3": 0, ".wav": 1, ".ogg": 2}
    best = {}
    for p in paths:
        if p.suffix in order and (p.stem not in best or order[p.suffix] < order[best[p.stem].suffix]):
            best[p.stem] = p
    return list(best.values())


def read_ogg(path):
    raw = subprocess.run(
        ["ffmpeg", "-v", "quiet", "-i", str(path), "-ac", "1", "-f", "f32le", "-"],
        capture_output=True, check=True).stdout
    return np.frombuffer(raw, dtype=np.float32).astype(np.float64)


def measure(x):
    peak = np.max(np.abs(x)) if len(x) else 0.0
    loud = x[np.abs(x) > 10 ** (-50 / 20)]
    rms = np.sqrt(np.mean(loud ** 2)) if len(loud) else 0.0
    return db(peak), db(rms)


def group(paths, reader):
    return {p.stem: measure(reader(p)) for p in sorted(paths)}


def outliers(levels, headroom=0.0):
    med = float(np.median([r for _, r in levels.values()]))
    bad = []
    for name, (peak, rms) in levels.items():
        if peak >= CLIP:
            bad.append(f"{name}: clips (peak {peak:.1f} dBFS)")
        elif abs(rms - med) > SPREAD - headroom:
            bad.append(f"{name}: loudness {rms:.1f} dB, {rms - med:+.1f} from the median {med:.1f}")
    return med, bad


def main():
    sfx = group(SFX.glob("*.wav"), read_wav)
    tracks = played(MUSIC.iterdir())
    music = group([p for p in tracks if not p.stem.startswith("amb_")], read_ogg)
    amb = group([p for p in tracks if p.stem.startswith("amb_")], read_ogg)
    problems = []
    for title, levels in (("Sound effects", sfx), ("Music", music), ("Ambience", amb)):
        med, bad = outliers(levels, HEADROOM if levels is sfx else 0.0)
        print(f"{title}: {len(levels)} files, median loudness {med:.1f} dB")
        if "--check" not in sys.argv:
            for name, (peak, rms) in levels.items():
                print(f"  {name:24s} peak {peak:6.1f}  rms {rms:6.1f}")
        for b in bad:
            print("  OUTLIER " + b)
        problems += bad
    if "--check" in sys.argv and problems:
        sys.exit(1)


if __name__ == "__main__":
    main()
