#!/usr/bin/env python3
"""Synthesizes placeholder music loops and ambience beds into assets/music/*.ogg.

The design bible (13.1, 13.3) has the real soundtrack coming from Sean's music
library. Until a track is supplied, these stand in: small seeded arrangements
(pads, plucked arpeggios, bass, a lead melody built from a motif, soft drums)
rendered as seamless loops. Drop a real file with the same name (any of .ogg,
.mp3 or .wav) into assets/music/ and the game plays that instead.

Needs numpy and ffmpeg (for Ogg Vorbis). Deterministic: same seed, same files.
Usage: python3 tools/audio/musicgen.py [track ...]
"""
import math
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

import numpy as np

RATE = 32000
OUT = Path(__file__).resolve().parents[2] / "assets" / "music"

NOTE = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}
SCALES = {
    "minor": [0, 2, 3, 5, 7, 8, 10],
    "dorian": [0, 2, 3, 5, 7, 9, 10],
    "major": [0, 2, 4, 5, 7, 9, 11],
    "lydian": [0, 2, 4, 6, 7, 9, 11],
    "phrygian": [0, 1, 3, 5, 7, 8, 10],
    "mixolydian": [0, 2, 4, 5, 7, 9, 10],
    "locrian": [0, 1, 3, 5, 6, 8, 10],
}


def midi_hz(m):
    return 440.0 * 2 ** ((m - 69) / 12)


# --- DSP -----------------------------------------------------------------------------
def fft_filter(x, low=None, high=None, order=4):
    """Smooth low/high-pass in the frequency domain (fast for long buffers)."""
    n = len(x)
    if n == 0:
        return x
    size = 1 << (n - 1).bit_length()
    spec = np.fft.rfft(x, size)
    f = np.fft.rfftfreq(size, 1 / RATE)
    gain = np.ones_like(f)
    if low:
        gain /= np.sqrt(1 + (f / low) ** (2 * order))
    if high:
        gain *= 1 - 1 / np.sqrt(1 + (f / high) ** (2 * order))
    return np.fft.irfft(spec * gain, size)[:n]


def adsr(n, a=0.01, d=0.1, s=0.7, r=0.1):
    e = np.full(n, s)
    na, nd, nr = int(a * RATE), int(d * RATE), int(r * RATE)
    na = min(na, n)
    e[:na] = np.linspace(0, 1, na)
    nd = min(nd, n - na)
    e[na:na + nd] = np.linspace(1, s, nd)
    nr = min(nr, n)
    if nr:
        e[n - nr:] *= np.linspace(1, 0, nr)
    return e


def phase(freq, n, vib=0.0, vib_rate=5.0):
    t = np.arange(n) / RATE
    f = freq * (1 + vib * np.sin(2 * np.pi * vib_rate * t))
    return np.cumsum(f) / RATE % 1.0


def wave_of(shape, ph, duty=0.5):
    if shape == "square":
        return np.where(ph < duty, 1.0, -1.0)
    if shape == "tri":
        return 4.0 * np.abs(ph - 0.5) - 1.0
    if shape == "saw":
        return 2.0 * ph - 1.0
    return np.sin(2 * np.pi * ph)


# --- Instruments (each returns a mono note buffer) --------------------------------
def pad(freq, dur):
    n = int(dur * RATE)
    x = sum(wave_of("saw", phase(freq * d, n)) for d in (0.996, 1.0, 1.004)) / 3
    x += 0.5 * wave_of("sine", phase(freq / 2, n))
    return fft_filter(x, low=900) * adsr(n, 0.6, 0.4, 0.8, 0.8) * 0.35


def pluck(freq, dur, bright=1800):
    n = int(dur * RATE)
    x = wave_of("square", phase(freq, n), 0.3)
    e = np.exp(-np.arange(n) / RATE * 7.0)
    return fft_filter(x * e, low=bright) * adsr(n, 0.003, 0.0, 1.0, 0.03) * 0.28


def bass(freq, dur):
    n = int(dur * RATE)
    x = wave_of("tri", phase(freq, n)) + 0.3 * wave_of("square", phase(freq, n), 0.5)
    return fft_filter(x, low=700) * adsr(n, 0.005, 0.08, 0.75, 0.04) * 0.45


def lead(freq, dur):
    n = int(dur * RATE)
    x = wave_of("square", phase(freq, n, vib=0.006, vib_rate=5.5), 0.25)
    return fft_filter(x, low=2200) * adsr(n, 0.02, 0.15, 0.6, 0.12) * 0.2


def bell(freq, dur):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    mod = np.sin(2 * np.pi * freq * 3.5 * t) * 2.0 * np.exp(-t * 3)
    x = np.sin(2 * np.pi * freq * t + mod)
    return x * np.exp(-t * 2.2) * adsr(n, 0.002, 0.0, 1.0, 0.05) * 0.3


def kick(dur=0.3):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    f = 45 + 110 * np.exp(-t * 30)
    return np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.exp(-t * 9) * 0.8


def snare(rng, dur=0.2):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    x = fft_filter(rng.uniform(-1, 1, n), low=6000, high=900) * np.exp(-t * 18)
    return (x + 0.4 * np.sin(2 * np.pi * 190 * t) * np.exp(-t * 25)) * 0.5


def hat(rng, dur=0.05):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    return fft_filter(rng.uniform(-1, 1, n), high=7000) * np.exp(-t * 60) * 0.12


def shaker(rng, dur=0.08):
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    return fft_filter(rng.uniform(-1, 1, n), high=4500, low=9000) * np.sin(np.pi * t / dur) * 0.18


# --- Arrangement -------------------------------------------------------------------------
class Song:
    def __init__(self, bpm, bars, beats=4):
        self.beat = 60.0 / bpm
        self.bar = self.beat * beats
        self.beats = beats
        self.length = int(self.bar * bars * RATE)
        # Render a little past the loop; the overflow wraps to the start.
        self.buf = np.zeros((self.length + RATE * 4, 2))

    def add(self, note, at_beats, pan=0.0, gain=1.0):
        i = int(at_beats * self.beat * RATE)
        left, right = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
        end = min(i + len(note), len(self.buf))
        self.buf[i:end, 0] += note[: end - i] * left * gain * 1.414
        self.buf[i:end, 1] += note[: end - i] * right * gain * 1.414

    def render(self, reverb=0.25):
        out = self.buf.copy()
        if reverb > 0:
            rng = np.random.default_rng(3)
            n = int(1.8 * RATE)
            t = np.arange(n) / RATE
            for ch in range(2):
                ir = rng.uniform(-1, 1, n) * np.exp(-t * 3.2)
                ir = fft_filter(ir, low=3500)
                ir[0] = 0
                size = 1 << (len(out) + n).bit_length()
                wet = np.fft.irfft(np.fft.rfft(out[:, ch], size) * np.fft.rfft(ir, size), size)[: len(out)]
                out[:, ch] += wet / (np.sqrt(np.sum(ir ** 2)) + 1e-9) * reverb * 0.6
        loop = out[: self.length].copy()
        tail = out[self.length:]
        loop[: len(tail)] += tail[: self.length]
        peak = np.max(np.abs(loop)) + 1e-9
        return loop / peak * 0.85


def chord_tones(root_midi, scale, degree, count=3):
    """Scale-degree triad (or more) starting at `degree` (0-based)."""
    out = []
    for k in range(count):
        d = degree + 2 * k
        out.append(root_midi + scale[d % 7] + 12 * (d // 7))
    return out


def scale_note(root_midi, scale, degree):
    return root_midi + scale[degree % 7] + 12 * (degree // 7)


def motif(rng, length_beats, chord_degree, density=0.6):
    """A rhythm and contour on scale degrees: [(beat, dur, degree)]."""
    notes = []
    beat = 0.0
    deg = chord_degree + rng.choice([0, 2, 4])
    while beat < length_beats:
        dur = rng.choice([0.5, 0.5, 1.0, 1.0, 1.5, 2.0]) if rng.random() < density else 1.0
        if beat + dur > length_beats:
            dur = length_beats - beat
        rest = rng.random() < 0.18
        if not rest:
            notes.append((beat, dur, deg))
        step = rng.choice([-2, -1, -1, 1, 1, 2, 3, -3])
        deg = max(chord_degree - 3, min(chord_degree + 7, deg + step))
        beat += dur
    return notes


def melody(song, rng, root, scale, prog, inst, start_bar=0, octave=12, pan=0.2, gain=1.0, density=0.6):
    """A-A'-B-A form over the progression, two bars per phrase."""
    bars = len(prog)
    phrase_a = motif(rng, song.beats * 2, prog[0], density)
    phrase_b = motif(rng, song.beats * 2, prog[len(prog) // 2 % len(prog)], density)
    for p in range(start_bar, bars, 2):
        section = (p // 2) % 4
        notes = phrase_b if section == 2 else phrase_a
        shift = prog[p % bars] - prog[0] if section != 2 else 0
        for beat, dur, deg in notes:
            d = deg + (shift if section == 1 else 0)
            m = scale_note(root + octave, scale, d)
            song.add(inst(midi_hz(m), dur * song.beat * 0.95), p * song.beats + beat, pan, gain)


def write_ogg(name, stereo):
    OUT.mkdir(parents=True, exist_ok=True)
    data = (np.clip(stereo, -1, 1) * 32767).astype(np.int16)
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / "x.wav"
        with wave.open(str(wav), "wb") as w:
            w.setnchannels(2)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(data.tobytes())
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-c:a", "libvorbis", "-q:a", "4",
                        str(OUT / f"{name}.ogg")], check=True)


# --- Tracks ------------------------------------------------------------------------------
def track_title():
    rng = np.random.default_rng(11)
    s = Song(bpm=68, bars=16)
    root, scale = 50, SCALES["minor"]  # D minor
    prog = [0, 5, 3, 4, 0, 5, 6, 4] * 2
    for b, deg in enumerate(prog):
        for m in chord_tones(root, scale, deg):
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.4, 0.4), 0.8)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.bar * 0.95), b * 4, 0, 0.6)
    melody(s, rng, root, scale, prog, bell, start_bar=4, octave=12, pan=0.3, gain=0.9, density=0.3)
    return s.render(reverb=0.5)


def track_eolis():
    rng = np.random.default_rng(23)
    s = Song(bpm=92, bars=16)
    root, scale = 53, SCALES["lydian"]  # F lydian: warm, a little wistful
    prog = [0, 4, 5, 3, 0, 4, 1, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, 0.0, 0.45)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 1.9), b * 4, 0, 0.8)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg + 4)), s.beat * 1.9), b * 4 + 2, 0, 0.6)
        arp = tones + [tones[0] + 12]
        for k in range(8):
            m = arp[[0, 1, 2, 3, 2, 1, 2, 3][k]] + 12
            s.add(pluck(midi_hz(m), s.beat * 0.5), b * 4 + k * 0.5, -0.35, 0.55)
        for k in range(4):
            s.add(shaker(rng), b * 4 + k + 0.5, 0.3, 0.8)
    melody(s, rng, root, scale, prog, lead, start_bar=4, octave=12, pan=0.15, gain=0.8)
    return s.render(reverb=0.3)


def track_trunk():
    rng = np.random.default_rng(37)
    s = Song(bpm=100, bars=16)
    root, scale = 45, SCALES["dorian"]  # A dorian: green, mysterious
    prog = [0, 0, 6, 3, 0, 0, 5, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.5, 0.5), 0.4)
        for k in range(8):
            if k in (0, 3, 6):
                s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 0.9), b * 4 + k * 0.5, 0, 0.8)
        for k in range(8):
            m = tones[[0, 2, 1, 2, 0, 2, 1, 2][k]] + 12
            s.add(pluck(midi_hz(m), s.beat * 0.5, bright=1600), b * 4 + k * 0.5, 0.4, 0.45)
        # A hollow hand drum.
        for k, g in [(0, 1.0), (1.5, 0.5), (2.5, 0.7)]:
            s.add(kick(0.25) * 0.5, b * 4 + k, 0, g)
        if b % 2:
            s.add(snare(rng) * 0.4, b * 4 + 3, 0.2)
    melody(s, rng, root, scale, prog, bell, start_bar=8, octave=24, pan=-0.2, gain=0.7, density=0.4)
    return s.render(reverb=0.45)


def anvil(rng, freq=1200.0, dur=0.6):
    """A struck anvil: inharmonic partials that ring and die away."""
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    out = np.zeros(n)
    for ratio, g in [(1.0, 1.0), (2.76, 0.5), (5.4, 0.25), (8.93, 0.12)]:
        out += np.sin(2 * np.pi * freq * ratio * t) * g * np.exp(-t * (6 + ratio * 2))
    out += fft_filter(rng.uniform(-1, 1, n), high=3000) * np.exp(-t * 60) * 0.4
    return out * 0.3


def track_tower():
    rng = np.random.default_rng(41)
    s = Song(bpm=92, bars=16)
    root, scale = 43, SCALES["phrygian"]  # G phrygian: dark, metal, dwarven
    prog = [0, 0, 1, 0, 0, 6, 1, 0] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones[:2]:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.4, 0.4), 0.35)
        # A plodding bass in fifths, like a hauling chant.
        for k in range(4):
            off = 0 if k % 2 == 0 else 4
            s.add(bass(midi_hz(scale_note(root - 12, scale, deg + off)), s.beat * 0.85), b * 4 + k, 0, 0.8)
        # Hammer on the one and three, an anvil ring on the four.
        s.add(kick(0.3) * 0.7, b * 4, 0, 1.0)
        s.add(kick(0.3) * 0.5, b * 4 + 2, 0, 0.8)
        s.add(anvil(rng, rng.choice([1180.0, 1240.0])), b * 4 + 3, rng.uniform(-0.6, 0.6), 0.5)
        for k in range(8):
            s.add(hat(rng) * 0.5, b * 4 + k * 0.5, 0.3, 0.3 if k % 2 else 0.5)
    melody(s, rng, root, scale, prog, lead, start_bar=4, octave=12, pan=-0.15, gain=0.55, density=0.5)
    melody(s, rng, root, scale, prog, bell, start_bar=8, octave=24, pan=0.3, gain=0.35, density=0.3)
    return s.render(reverb=0.5)


def track_boss():
    rng = np.random.default_rng(51)
    s = Song(bpm=148, bars=16)
    root, scale = 40, SCALES["phrygian"]  # E phrygian: menace
    prog = [0, 0, 1, 0, 0, 0, 5, 6] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root + 12, scale, deg)
        for k in range(8):
            s.add(bass(midi_hz(scale_note(root - 12, scale, deg) + (12 if k % 4 == 3 else 0)), s.beat * 0.45), b * 4 + k * 0.5, 0, 0.9)
        for k in (0, 1.5, 3):
            for m in tones:
                s.add(pluck(midi_hz(m + 12), s.beat * 0.4, bright=2200), b * 4 + k, rng.uniform(-0.3, 0.3), 0.35)
        for k in range(4):
            s.add(kick(), b * 4 + k, 0, 0.9)
            s.add(hat(rng), b * 4 + k + 0.5, 0.3)
        s.add(snare(rng), b * 4 + 1, -0.1)
        s.add(snare(rng), b * 4 + 3, -0.1)
    melody(s, rng, root, scale, prog, lead, start_bar=0, octave=24, pan=0.1, gain=0.9, density=0.8)
    return s.render(reverb=0.2)


def track_miniboss():
    """The Foreman: a work song turned into a fight. Hammer-and-anvil drums under a
    driving bass in D phrygian, faster than the tower, slower than a boss."""
    rng = np.random.default_rng(53)
    s = Song(bpm=128, bars=16)
    root, scale = 38, SCALES["phrygian"]
    prog = [0, 0, 1, 0, 6, 6, 1, 0] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root + 12, scale, deg)
        for k in range(8):
            s.add(bass(midi_hz(scale_note(root - 12, scale, deg) + (7 if k % 4 == 2 else 0)), s.beat * 0.45), b * 4 + k * 0.5, 0, 0.85)
        for m in tones[:2]:
            s.add(pad(midi_hz(m), s.bar * 1.02), b * 4, rng.uniform(-0.4, 0.4), 0.25)
        # The hammer falls on every beat; the anvil answers on the off-beats of two and four.
        for k in range(4):
            s.add(kick(0.3), b * 4 + k, 0, 0.9)
        for k in (1.5, 3.5):
            s.add(anvil(rng, rng.choice([1180.0, 1320.0]), 0.4), b * 4 + k, rng.uniform(-0.5, 0.5), 0.45)
        s.add(snare(rng), b * 4 + 2, -0.1, 0.8)
    melody(s, rng, root, scale, prog, lead, start_bar=4, octave=24, pan=0.1, gain=0.75, density=0.65)
    return s.render(reverb=0.3)


def track_zoradohna():
    """Zoradohna: the drill engine. A relentless sixteenth-note bass in E minor
    that churns like a gearbox, kick on every beat, the anvil on every
    off-beat, and a minor-key lead from bar 5. The tower's boss theme."""
    rng = np.random.default_rng(61)
    s = Song(bpm=144, bars=16)
    root, scale = 40, SCALES["minor"]
    prog = [0, 0, 5, 6, 0, 0, 3, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root + 12, scale, deg)
        base = scale_note(root - 12, scale, deg)
        for k in range(16):
            # The engine: root, root, octave, fifth, churning.
            m = base + [0, 0, 12, 7][k % 4]
            s.add(bass(midi_hz(m), s.beat * 0.22), b * 4 + k * 0.25, 0, 0.7)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.02), b * 4, rng.uniform(-0.5, 0.5), 0.2)
        for k in range(4):
            s.add(kick(0.25), b * 4 + k, 0, 0.95)
            s.add(anvil(rng, rng.choice([1240.0, 1400.0]), 0.3), b * 4 + k + 0.5, rng.uniform(-0.6, 0.6), 0.35)
        for k in (1, 3):
            s.add(snare(rng), b * 4 + k, -0.1, 0.85)
        for k in range(8):
            s.add(hat(rng), b * 4 + k * 0.5 + 0.25, 0.3, 0.3)
    melody(s, rng, root, scale, prog, lead, start_bar=4, octave=24, pan=-0.1, gain=0.8, density=0.75)
    return s.render(reverb=0.28)


def track_ripasheiku():
    """Ripasheiku, the Lantern Widow: the Mist's drowned waltz turned hunter. B
    phrygian in a fast 3/4, a creeping bass that climbs a half step, skittering
    ticks like many legs on stone, lantern bells tolling the chord, a heartbeat
    kick on the downbeat, and a bell lead from bar 5."""
    rng = np.random.default_rng(103)
    s = Song(bpm=168, bars=24, beats=3)
    root, scale = 47, SCALES["phrygian"]
    prog = [0, 0, 1, 0, 5, 5, 1, 0, 0, 0, 1, 0, 3, 4, 1, 1] + [0, 1] * 4
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        base = scale_note(root - 12, scale, deg)
        # The creep: root, root, a half step up, on every beat.
        for k, step in enumerate([0, 0, 1]):
            s.add(bass(midi_hz(base + step), s.beat * 0.8), b * 3 + k, 0, 0.75)
        for m in tones:
            s.add(fft_filter(pad(midi_hz(m), s.bar * 1.05), low=1600), b * 3, rng.uniform(-0.6, 0.6), 0.3)
        # Lantern bells toll the chord on the downbeat, wide in the stereo field.
        if b % 2 == 0:
            s.add(bell(midi_hz(tones[0] + 24), s.bar * 1.5), b * 3, rng.uniform(-0.7, 0.7), 0.25)
        # Heartbeat on one, a softer echo just after.
        s.add(kick(0.3), b * 3, 0, 0.9)
        s.add(kick(0.3) * 0.5, b * 3 + 0.35, 0, 0.8)
        s.add(snare(rng), b * 3 + 2, -0.1, 0.6)
        # Legs on stone: short ticks on every sixteenth, some skipped, panned about.
        for k in range(12):
            if rng.random() < 0.75:
                s.add(hat(rng, 0.03), b * 3 + k * 0.25, rng.uniform(-0.8, 0.8), 0.22 + 0.1 * (k % 4 == 0))
    melody(s, rng, root, scale, prog, bell, start_bar=4, octave=24, pan=0.15, gain=0.6, density=0.6)
    return s.render(reverb=0.5)


def track_zorugeriru():
    """Zorugeriru, the Mist Hydra: a heavy surge in C# minor. The bass swells and
    falls like water in a tank, a war-drum pattern rolls under it, and three
    voices (the heads) trade one motif left, centre and right, a bar each, while
    a fourth answers low from bar 9. Slower than the widow, heavier than the
    generic boss theme."""
    rng = np.random.default_rng(109)
    s = Song(bpm=132, bars=16)
    root, scale = 37, SCALES["minor"]
    prog = [0, 0, 5, 6, 0, 3, 4, 4] * 2
    motif = [0, 2, 3, 2, 4, 3]
    for b, deg in enumerate(prog):
        tones = chord_tones(root + 12, scale, deg)
        base = scale_note(root - 12, scale, deg)
        # The surge: a long bass note swelling into the bar, a push on four.
        s.add(fft_filter(pad(midi_hz(base), s.bar * 0.9), low=500), b * 4, 0, 0.8)
        s.add(bass(midi_hz(base), s.beat * 1.4), b * 4, 0, 0.8)
        s.add(bass(midi_hz(base + 7), s.beat * 0.45), b * 4 + 3, 0, 0.6)
        s.add(bass(midi_hz(base + 12), s.beat * 0.45), b * 4 + 3.5, 0, 0.6)
        for m in tones:
            s.add(fft_filter(pad(midi_hz(m), s.bar * 1.02), low=1400), b * 4, rng.uniform(-0.5, 0.5), 0.22)
        # War drums: a rolling triplet into the downbeat.
        s.add(kick(0.35), b * 4, 0, 1.0)
        s.add(kick(0.3), b * 4 + 2, 0, 0.8)
        for k in (2.67, 3.0, 3.33):
            s.add(kick(0.2) * 0.6, b * 4 + k + 0.33, 0, 0.6)
        s.add(snare(rng), b * 4 + 1, -0.1, 0.7)
        s.add(snare(rng), b * 4 + 3, -0.1, 0.5)
        # The heads: each bar one of three voices sings the motif, panned to its lane.
        head = b % 3
        pan = [-0.7, 0.0, 0.7][head]
        for k, step in enumerate(motif):
            m = scale_note(root + 24, scale, deg + step)
            s.add(lead(midi_hz(m + [0, 0, -12][head] + 0), s.beat * 0.55), b * 4 + k * 0.5, pan, 0.38)
        if b >= 8:
            # The fourth head, low and late.
            s.add(bell(midi_hz(tones[0]), s.beat * 1.5), b * 4 + 2.5, 0.0, 0.3)
    return s.render(reverb=0.4)


def track_forepaw():
    """Forepaw freed: the dwarves' city breathes again. A warm work song in G
    major, anvils ringing in time, a plucked tune over a slow pad."""
    rng = np.random.default_rng(67)
    s = Song(bpm=96, bars=16)
    root, scale = 43, SCALES["major"]
    prog = [0, 3, 4, 0, 5, 3, 4, 0] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root + 12, scale, deg)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 1.6), b * 4, 0, 0.7)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg) + 7), s.beat * 1.6), b * 4 + 2, 0, 0.55)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.4, 0.4), 0.3)
        for k in (0, 2):
            s.add(anvil(rng, rng.choice([1180.0, 1320.0, 1480.0]), 0.5), b * 4 + k + 1, rng.uniform(-0.6, 0.6), 0.3)
    melody(s, rng, root, scale, prog, pluck, start_bar=2, octave=24, pan=0.15, gain=0.7, density=0.55)
    return s.render(reverb=0.35)


def track_mist():
    """The Mist: slow and drifting, a music box heard through fog, with a lantern-bell
    melody and no drums, only a heartbeat thump now and then."""
    rng = np.random.default_rng(97)
    s = Song(bpm=66, bars=16, beats=3)
    root, scale = 47, SCALES["minor"]  # B minor in 3/4: a drowned waltz
    prog = [0, 5, 3, 4, 0, 5, 1, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(fft_filter(pad(midi_hz(m), s.bar * 1.1), low=1400), b * 3, rng.uniform(-0.6, 0.6), 0.45)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 2.6), b * 3, 0, 0.55)
        # The waltz: a soft pluck on two and three, as from a music box under water.
        for k in (1, 2):
            m = tones[k] + 12
            s.add(fft_filter(pluck(midi_hz(m), s.beat * 0.8, bright=1200), low=2200), b * 3 + k, 0.35, 0.35)
        if b % 4 == 3:
            s.add(kick(0.4) * 0.35, b * 3, 0, 0.8)
            s.add(kick(0.4) * 0.25, b * 3 + 0.4, 0, 0.8)
    melody(s, rng, root, scale, prog, bell, start_bar=2, octave=24, pan=-0.25, gain=0.55, density=0.35)
    return s.render(reverb=0.65)


def amb_mist():
    """Fog on a drowned marsh: a damp hush, water lapping at the boardwalks, frogs
    and far-off bird calls, and now and then the creak of a lantern on its cord."""
    rng = np.random.default_rng(101)
    dur = 26.0
    n = int(dur * RATE)
    m = n + RATE * 3
    out = np.zeros((m, 2))
    hush = fft_filter(rng.uniform(-1, 1, m), low=380, high=60) * 1.6
    out[:, 0] += hush
    out[:, 1] += np.roll(hush, RATE // 3)
    # Lapping water: soft filtered splashes in slow pairs.
    for _ in range(22):
        i = rng.integers(0, n)
        mm = int(0.35 * RATE)
        t = np.arange(mm) / RATE
        lap = fft_filter(rng.uniform(-1, 1, mm), low=900, high=150) * np.sin(np.pi * t / t[-1]) ** 2 * rng.uniform(0.3, 0.6)
        pan = rng.uniform(-1, 1)
        out[i:i + mm, 0] += lap * (1 - pan) / 2
        out[i:i + mm, 1] += lap * (1 + pan) / 2
    # Frogs: low croaks in short runs.
    for _ in range(6):
        i = rng.integers(0, n)
        f0 = rng.uniform(110, 170)
        for k in range(rng.integers(2, 5)):
            j = i + int(k * 0.28 * RATE)
            mm = int(0.16 * RATE)
            t = np.arange(mm) / RATE
            croak = wave_of("square", np.cumsum(f0 * (1 + 0.3 * np.sin(2 * np.pi * 30 * t))) / RATE % 1.0, 0.3)
            croak = fft_filter(croak, low=900) * np.sin(np.pi * t / t[-1]) * 0.12
            pan = rng.uniform(-1, 1)
            out[j:j + mm, 0] += croak * (1 - pan) / 2
            out[j:j + mm, 1] += croak * (1 + pan) / 2
    # A far bird call: two falling whistles.
    for _ in range(3):
        i = rng.integers(0, n)
        for k in range(2):
            j = i + int(k * 0.5 * RATE)
            mm = int(0.4 * RATE)
            t = np.arange(mm) / RATE
            f = rng.uniform(1500, 1900) * np.exp(-t * 1.2)
            call = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.sin(np.pi * t / t[-1]) * 0.05
            out[j:j + mm, 0] += call * 0.4
            out[j:j + mm, 1] += call
    # A lantern swinging on its cord.
    for _ in range(4):
        i = rng.integers(0, n)
        mm = int(rng.uniform(0.6, 1.0) * RATE)
        tt = np.arange(mm) / RATE
        fc = rng.uniform(150, 220) + 20 * np.sin(2 * np.pi * 13 * tt)
        creak = fft_filter(wave_of("saw", np.cumsum(fc) / RATE % 1.0), low=900) * np.sin(np.pi * tt / tt[-1]) * 0.08
        out[i:i + mm, :] += creak[:, None]
    loop = out[:n].copy()
    loop[: m - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.5


def track_branches():
    """Branches (Conflate): sunlight high in the canopy. D lydian at a lilting 104,
    bright plucks rippling like leaves in the wind, a warm pad, a light shaker
    and kick, and an airy bell lead. The first open sky of the game."""
    rng = np.random.default_rng(113)
    s = Song(bpm=104, bars=16)
    root, scale = 50, SCALES["lydian"]
    prog = [0, 1, 0, 4, 5, 1, 4, 0] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.05), b * 4, rng.uniform(-0.5, 0.5), 0.3)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 1.8), b * 4, 0, 0.55)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg) + 7), s.beat * 0.9), b * 4 + 2.5, 0, 0.45)
        # Leaves in the wind: a rippling arpeggio up and back down the chord.
        arp = [tones[0], tones[1], tones[2], tones[0] + 12, tones[2], tones[1]]
        for k in range(8):
            m = arp[k % len(arp)] + 12
            s.add(pluck(midi_hz(m), s.beat * 0.45, bright=2600), b * 4 + k * 0.5, 0.4 * math.sin(k), 0.28)
        s.add(kick(0.25) * 0.6, b * 4, 0, 0.8)
        s.add(kick(0.25) * 0.4, b * 4 + 2, 0, 0.8)
        for k in range(8):
            s.add(hat(rng, 0.04), b * 4 + k * 0.5 + 0.25, 0.5, 0.18)
    melody(s, rng, root, scale, prog, bell, start_bar=2, octave=24, pan=-0.2, gain=0.6, density=0.5)
    return s.render(reverb=0.45)


def amb_branches():
    """Wind through the high canopy: a long airy gust that swells and fades, leaves
    rustling in bursts, a far bird trill, and a bough creaking under the wind."""
    rng = np.random.default_rng(117)
    dur = 26.0
    n = int(dur * RATE)
    m = n + RATE * 3
    out = np.zeros((m, 2))
    t = np.arange(m) / RATE
    gust = 0.55 + 0.45 * np.sin(2 * np.pi * t / 13.0) * np.sin(2 * np.pi * t / 5.2 + 1.0)
    wind = fft_filter(rng.uniform(-1, 1, m), low=900, high=180) * 1.4 * gust
    out[:, 0] += wind
    out[:, 1] += np.roll(wind, RATE // 4)
    # Rustling leaves: bright crackles in short bursts.
    for _ in range(30):
        i = rng.integers(0, n)
        mm = int(rng.uniform(0.3, 0.8) * RATE)
        tt = np.arange(mm) / RATE
        rustle = fft_filter(rng.uniform(-1, 1, mm) * (rng.random(mm) < 0.3), low=7000, high=2500)
        rustle *= np.sin(np.pi * tt / tt[-1]) * rng.uniform(0.15, 0.35)
        pan = rng.uniform(-1, 1)
        out[i:i + mm, 0] += rustle * (1 - pan) / 2
        out[i:i + mm, 1] += rustle * (1 + pan) / 2
    # A bird trill: quick rising chirps.
    for _ in range(5):
        i = rng.integers(0, n)
        for k in range(rng.integers(3, 6)):
            j = i + int(k * 0.09 * RATE)
            mm = int(0.07 * RATE)
            tt = np.arange(mm) / RATE
            f = rng.uniform(2600, 3200) * (1 + tt * 6)
            chirp = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.sin(np.pi * tt / tt[-1]) * 0.05
            pan = rng.uniform(-0.8, 0.8)
            out[j:j + mm, 0] += chirp * (1 - pan) / 2
            out[j:j + mm, 1] += chirp * (1 + pan) / 2
    # A bough creaking.
    for _ in range(3):
        i = rng.integers(0, n)
        mm = int(rng.uniform(0.8, 1.3) * RATE)
        tt = np.arange(mm) / RATE
        fc = rng.uniform(80, 120) + 15 * np.sin(2 * np.pi * 7 * tt)
        creak = fft_filter(wave_of("saw", np.cumsum(fc) / RATE % 1.0), low=700) * np.sin(np.pi * tt / tt[-1]) * 0.07
        out[i:i + mm, :] += creak[:, None]
    loop = out[:n].copy()
    loop[: m - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.5


def amb_trunk():
    rng = np.random.default_rng(71)
    dur = 24.0
    n = int(dur * RATE)
    out = np.zeros((n + RATE * 3, 2))
    rumble = fft_filter(rng.uniform(-1, 1, len(out)), low=120) * 3.0
    out[:, 0] += rumble
    out[:, 1] += rumble
    # Drips: short sine blips falling in pitch, at random places.
    for _ in range(26):
        i = rng.integers(0, n)
        m = int(0.12 * RATE)
        t = np.arange(m) / RATE
        f = rng.uniform(900, 1700) * np.exp(-t * 6)
        drip = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.exp(-t * 30) * rng.uniform(0.2, 0.5)
        pan = rng.uniform(-1, 1)
        out[i:i + m, 0] += drip * (1 - pan) / 2
        out[i:i + m, 1] += drip * (1 + pan) / 2
    # Creaks of the living wood.
    for _ in range(5):
        i = rng.integers(0, n)
        m = int(rng.uniform(0.6, 1.2) * RATE)
        t = np.arange(m) / RATE
        f = rng.uniform(70, 110) + 8 * np.sin(2 * np.pi * 23 * t)
        creak = fft_filter(wave_of("saw", np.cumsum(f) / RATE % 1.0), low=700) * np.sin(np.pi * t / t[-1]) * 0.25
        out[i:i + m, :] += creak[:, None]
    loop = out[:n].copy()
    loop[: len(out) - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.6


def amb_eolis():
    rng = np.random.default_rng(73)
    dur = 20.0
    n = int(dur * RATE)
    t = np.arange(n) / RATE
    wind = fft_filter(rng.uniform(-1, 1, n), low=500, high=80)
    swell = 0.6 + 0.4 * np.sin(2 * np.pi * t / dur) * np.sin(2 * np.pi * 3 * t / dur)
    left = wind * swell
    right = np.roll(wind, RATE // 3) * swell
    out = np.stack([left, right], axis=1)
    return out / (np.max(np.abs(out)) + 1e-9) * 0.5


def amb_tower():
    """Machinery deep in the walls: a low hum, distant hammer strikes, chain rattles."""
    rng = np.random.default_rng(79)
    dur = 22.0
    n = int(dur * RATE)
    t_all = np.arange(n + RATE * 3) / RATE
    out = np.zeros((n + RATE * 3, 2))
    hum = np.sin(2 * np.pi * 55 * t_all) * 0.15 + fft_filter(rng.uniform(-1, 1, len(out)), low=200) * 1.5
    hum *= 0.8 + 0.2 * np.sin(2 * np.pi * t_all / 5.5)
    out[:, 0] += hum
    out[:, 1] += hum
    for _ in range(9):
        i = rng.integers(0, n)
        hit = anvil(rng, rng.uniform(700, 1300), 1.2) * rng.uniform(0.15, 0.35)
        hit = fft_filter(hit, low=2000)
        pan = rng.uniform(-1, 1)
        out[i:i + len(hit), 0] += hit * (1 - pan) / 2
        out[i:i + len(hit), 1] += hit * (1 + pan) / 2
    for _ in range(4):
        i = rng.integers(0, n)
        m = int(0.7 * RATE)
        tt = np.arange(m) / RATE
        rattle = fft_filter(rng.uniform(-1, 1, m), high=2500, low=7000) * (np.sin(2 * np.pi * 18 * tt) > 0.3)
        rattle = rattle * np.sin(np.pi * tt / tt[-1]) * 0.15
        out[i:i + m, :] += rattle[:, None]
    loop = out[:n].copy()
    loop[: len(out) - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.55


def amb_heights():
    """Wind high in the tower: a hollow howl through the flue and the rafters,
    gusts, a loose shutter rattling and roof beams creaking."""
    rng = np.random.default_rng(83)
    dur = 24.0
    n = int(dur * RATE)
    t_all = np.arange(n + RATE * 3) / RATE
    m = len(t_all)
    out = np.zeros((m, 2))
    gust = fft_filter(rng.uniform(-1, 1, m), low=0.4)
    gust = 0.55 + 0.45 * gust / (np.max(np.abs(gust)) + 1e-9)
    wind = fft_filter(rng.uniform(-1, 1, m), low=900, high=120) * gust
    out[:, 0] += wind
    out[:, 1] += np.roll(wind, RATE // 4)
    # The howl: a breathy tone that bends with the gusts.
    f = 300 + 70 * np.sin(2 * np.pi * t_all / 7.3) + 35 * np.sin(2 * np.pi * t_all / 2.9) + 60 * (gust - 0.55)
    breath = 0.55 + 0.45 * fft_filter(rng.uniform(-1, 1, m), low=30) / 0.3
    howl = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.clip(breath, 0, 1.4) * (gust - 0.2) * 0.22
    howl2 = np.sin(2 * np.pi * np.cumsum(f * 1.5) / RATE) * (gust - 0.3).clip(0) * 0.06
    out[:, 0] += howl + howl2 * 0.6
    out[:, 1] += howl * 0.8 + howl2
    # A loose shutter knocking in its frame.
    for _ in range(5):
        i = rng.integers(0, n)
        for k in range(rng.integers(3, 7)):
            j = i + int(k * rng.uniform(0.07, 0.14) * RATE)
            hit = fft_filter(rng.uniform(-1, 1, int(0.05 * RATE)), low=1800, high=200)
            hit *= np.exp(-np.arange(len(hit)) / RATE * 70) * rng.uniform(0.25, 0.45)
            pan = rng.uniform(-0.8, 0.8)
            out[j:j + len(hit), 0] += hit * (1 - pan) / 2
            out[j:j + len(hit), 1] += hit * (1 + pan) / 2
    # Roof beams creaking under the wind.
    for _ in range(4):
        i = rng.integers(0, n)
        mm = int(rng.uniform(0.7, 1.3) * RATE)
        tt = np.arange(mm) / RATE
        fc = rng.uniform(60, 95) + 10 * np.sin(2 * np.pi * 19 * tt)
        creak = fft_filter(wave_of("saw", np.cumsum(fc) / RATE % 1.0), low=650) * np.sin(np.pi * tt / tt[-1]) * 0.22
        out[i:i + mm, :] += creak[:, None]
    loop = out[:n].copy()
    loop[: m - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.55


def amb_mine():
    """The Deep Workings: a stone hush, water dripping into sumps, a cart
    rumbling past somewhere in the rock, and far-off picks."""
    rng = np.random.default_rng(89)
    dur = 26.0
    n = int(dur * RATE)
    m = n + RATE * 3
    out = np.zeros((m, 2))
    hush = fft_filter(rng.uniform(-1, 1, m), low=160) * 2.5
    out[:, 0] += hush
    out[:, 1] += np.roll(hush, RATE // 5)
    for _ in range(30):
        i = rng.integers(0, n)
        mm = int(0.4 * RATE)
        t = np.arange(mm) / RATE
        f = rng.uniform(700, 1400) * np.exp(-t * 5)
        drip = np.sin(2 * np.pi * np.cumsum(f) / RATE) * np.exp(-t * 26) * rng.uniform(0.15, 0.4)
        # A faint echo off the shaft walls.
        echo = np.zeros(mm)
        d = int(0.11 * RATE)
        echo[d:] = drip[:-d] * 0.35
        pan = rng.uniform(-1, 1)
        out[i:i + mm, 0] += (drip + echo) * (1 - pan) / 2
        out[i:i + mm, 1] += (drip + echo * 0.8) * (1 + pan) / 2
    # Two carts passing deep in the rock: a swelling rumble with wheel clacks.
    for c in range(2):
        i = int((0.15 + 0.5 * c) * n + rng.integers(0, RATE * 2))
        mm = int(5.0 * RATE)
        t = np.arange(mm) / RATE
        swell = np.sin(np.pi * t / t[-1]) ** 2
        rumble = fft_filter(rng.uniform(-1, 1, mm), low=220, high=40) * swell * 2.2
        clack = np.zeros(mm)
        for k in np.arange(0.2, 4.8, 0.36):
            j = int(k * RATE)
            hit = fft_filter(rng.uniform(-1, 1, int(0.03 * RATE)), low=900)
            clack[j:j + len(hit)] += hit * np.exp(-np.arange(len(hit)) / RATE * 90)
        clack *= swell * 0.5
        pan = np.linspace(-0.7, 0.7, mm) * (1 if c == 0 else -1)
        out[i:i + mm, 0] += (rumble + clack) * (1 - pan) / 2
        out[i:i + mm, 1] += (rumble + clack) * (1 + pan) / 2
    for _ in range(7):
        i = rng.integers(0, n)
        hit = fft_filter(anvil(rng, rng.uniform(500, 800), 0.8), low=1200) * rng.uniform(0.08, 0.16)
        pan = rng.uniform(-1, 1)
        out[i:i + len(hit), 0] += hit * (1 - pan) / 2
        out[i:i + len(hit), 1] += hit * (1 + pan) / 2
    loop = out[:n].copy()
    loop[: m - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.55


def track_conflate():
    """Conflate, the elves' town in the boughs: a wistful harp waltz in E dorian,
    rippling arpeggios over a soft pad, a breathy lead, no drums. Warm, but the
    town is afraid of the Bloom above, so it leans minor."""
    rng = np.random.default_rng(127)
    s = Song(bpm=84, bars=16, beats=3)
    root, scale = 52, SCALES["dorian"]
    prog = [0, 3, 6, 0, 0, 3, 4, 6] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.1), b * 3, rng.uniform(-0.5, 0.5), 0.28)
        s.add(bass(midi_hz(scale_note(root - 12, scale, deg)), s.beat * 2.4), b * 3, 0, 0.5)
        # The harp: up the chord and back, a note every half beat.
        arp = [tones[0], tones[1], tones[2], tones[0] + 12, tones[2], tones[1]]
        for k in range(6):
            s.add(pluck(midi_hz(arp[k] + 12), s.beat * 0.9, bright=2200), b * 3 + k * 0.5, -0.3 + 0.12 * k, 0.3)
    melody(s, rng, root, scale, prog, lead, start_bar=2, octave=24, pan=0.2, gain=0.4, density=0.45)
    return s.render(reverb=0.55)


def track_pakukame():
    """Pakukame, the Devouring Bloom: a hungry, lurching fight in A phrygian at 140.
    A snapping bass on the offbeats (the jaws), chomp-chomp double kicks, a
    shaker like rustling leaves, and the Branches' bell lead turned sour, a
    half step flat of where the canopy theme sang."""
    rng = np.random.default_rng(131)
    s = Song(bpm=140, bars=16)
    root, scale = 45, SCALES["phrygian"]
    prog = [0, 1, 0, 6, 0, 1, 5, 6] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        base = scale_note(root - 12, scale, deg)
        for k in (0.5, 1.5, 2.5, 3.5):
            s.add(bass(midi_hz(base), s.beat * 0.35), b * 4 + k, 0, 0.75)
        s.add(bass(midi_hz(base - 12), s.beat * 0.9), b * 4, 0, 0.7)
        for m in tones:
            s.add(fft_filter(pad(midi_hz(m), s.bar * 1.0), low=1600), b * 4, rng.uniform(-0.5, 0.5), 0.2)
        # Paku-paku: two quick kicks, twice a bar.
        for k in (0, 0.25, 2, 2.25):
            s.add(kick(0.22), b * 4 + k, 0, 0.9)
        s.add(snare(rng), b * 4 + 1, 0.1, 0.6)
        s.add(snare(rng), b * 4 + 3, 0.1, 0.6)
        for k in range(8):
            s.add(shaker(rng), b * 4 + k * 0.5 + 0.25, 0.4, 0.25)
    melody(s, rng, root, scale, prog, bell, start_bar=2, octave=24, pan=-0.2, gain=0.45, density=0.55)
    return s.render(reverb=0.35)


def track_daybreak():
    """Branches (Daybreak): the storm over the Tree's crown. E dorian at a driving
    116, a low pulsing bass under tense open-fifth pads, toms like distant thunder,
    plucks blown about in the wind, and a bell lead that reaches for the light."""
    rng = np.random.default_rng(131)
    s = Song(bpm=116, bars=16)
    root, scale = 52, SCALES["dorian"]
    prog = [0, 0, 6, 3, 0, 5, 6, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        s.add(pad(midi_hz(tones[0]), s.bar * 1.05), b * 4, -0.4, 0.3)
        s.add(pad(midi_hz(tones[0] + 7), s.bar * 1.05), b * 4, 0.4, 0.26)
        low = scale_note(root - 24, scale, deg)
        for k in range(8):
            s.add(bass(midi_hz(low + (12 if k % 4 == 3 else 0)), s.beat * 0.42), b * 4 + k * 0.5, 0, 0.42)
        # Gusts: plucks scattered up the chord, never quite on the beat.
        for k in range(rng.integers(3, 6)):
            m = tones[rng.integers(0, 3)] + 12 * rng.integers(1, 3)
            s.add(pluck(midi_hz(m), s.beat * 0.5, bright=3200), b * 4 + rng.integers(0, 8) * 0.5 + 0.25,
                  rng.uniform(-0.8, 0.8), 0.22)
        s.add(kick(0.3) * 0.7, b * 4, 0, 0.8)
        s.add(kick(0.3) * 0.5, b * 4 + 1.5, 0, 0.8)
        s.add(kick(0.3) * 0.6, b * 4 + 2, 0, 0.8)
        if b % 2 == 1:
            # Thunder: a low tom roll at the bar's end.
            for k in range(4):
                s.add(kick(0.5) * (0.35 + 0.1 * k), b * 4 + 3 + k * 0.25, rng.uniform(-0.3, 0.3), 0.7)
        s.add(snare(rng, 0.2) * 0.5, b * 4 + 1, 0.1, 0.4)
        s.add(snare(rng, 0.2) * 0.5, b * 4 + 3, 0.1, 0.4)
        for k in range(8):
            s.add(hat(rng, 0.04), b * 4 + k * 0.5 + 0.25, 0.5, 0.15)
    melody(s, rng, root, scale, prog, bell, start_bar=4, octave=24, pan=-0.2, gain=0.55, density=0.55)
    return s.render(reverb=0.5)


def amb_daybreak():
    """Storm at the top of the world: a hard, gusting wind, rain hissing in waves,
    and thunder rolling in from far off now and then."""
    rng = np.random.default_rng(137)
    dur = 28.0
    n = int(dur * RATE)
    m = n + RATE * 4
    out = np.zeros((m, 2))
    t = np.arange(m) / RATE
    gust = 0.6 + 0.4 * np.sin(2 * np.pi * t / 9.0) * np.sin(2 * np.pi * t / 3.7 + 0.5)
    wind = fft_filter(rng.uniform(-1, 1, m), low=700, high=120) * 1.6 * gust
    out[:, 0] += wind
    out[:, 1] += np.roll(wind, RATE // 5)
    rain = fft_filter(rng.uniform(-1, 1, m), low=9000, high=3000) * 0.35 * (0.7 + 0.3 * np.sin(2 * np.pi * t / 7.0))
    out[:, 0] += rain
    out[:, 1] += np.roll(rain, RATE // 7)
    # Thunder: a crack, then a long low roll that fades.
    for i in (int(3.5 * RATE), int(14.0 * RATE), int(22.5 * RATE)):
        mm = int(rng.uniform(3.0, 4.5) * RATE)
        tt = np.arange(mm) / RATE
        env = np.exp(-tt * 0.9) * (1 + 0.5 * np.sin(2 * np.pi * tt * rng.uniform(1.5, 3.0)))
        roll = fft_filter(rng.uniform(-1, 1, mm), low=160) * 5.0 * env
        crack = fft_filter(rng.uniform(-1, 1, mm), low=3000, high=400) * np.exp(-tt * 9) * 0.6
        pan = rng.uniform(-0.6, 0.6)
        thunder = (roll + crack) * rng.uniform(0.6, 1.0)
        out[i:i + mm, 0] += thunder * (1 - pan) / 2
        out[i:i + mm, 1] += thunder * (1 + pan) / 2
    loop = out[:n].copy()
    loop[: m - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.5


def track_daybreak_town():
    """Daybreak, the bell town: a calm under the storm. G mixolydian at a gentle
    92, a carillon ringing the chord down from the top on every bar, warm pads,
    a walking bass and a soft harp lead. Hopeful, but the bells are a little
    out of time with each other, as if the wind is ringing them."""
    rng = np.random.default_rng(137)
    s = Song(bpm=92, bars=16)
    root, scale = 55, SCALES["mixolydian"]
    prog = [0, 3, 6, 0, 4, 3, 6, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(pad(midi_hz(m), s.bar * 1.1), b * 4, rng.uniform(-0.5, 0.5), 0.24)
        for k, step in enumerate((0, 2, 4, 2)):
            s.add(bass(midi_hz(scale_note(root - 12, scale, deg + step)), s.beat * 0.9), b * 4 + k, 0, 0.45)
        # The carillon: the chord rung down from the top, each bell a touch late.
        peal = [tones[2] + 12, tones[1] + 12, tones[0] + 12, tones[2]]
        for k, m in enumerate(peal):
            s.add(bell(midi_hz(m), s.beat * 1.6), b * 4 + k * 0.5 + rng.uniform(0.0, 0.06), -0.4 + 0.25 * k, 0.22)
    melody(s, rng, root, scale, prog, pluck, start_bar=2, octave=12, pan=0.25, gain=0.35, density=0.4)
    return s.render(reverb=0.5)


def track_borabohra():
    """Borabohra, the Storm Roc: the Daybreak storm theme turned into a fight.
    E minor at a galloping 150, a pounding eighth-note bass, thunder-roll toms
    every other bar, bright stabbed fifths like lightning, and the bell lead
    climbing high over the wind."""
    rng = np.random.default_rng(1987)
    s = Song(bpm=150, bars=16)
    root, scale = 52, SCALES["minor"]
    prog = [0, 5, 6, 0, 0, 3, 4, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        low = scale_note(root - 24, scale, deg)
        for k in range(8):
            s.add(bass(midi_hz(low + (12 if k % 2 == 1 else 0)), s.beat * 0.4), b * 4 + k * 0.5, 0, 0.5)
        s.add(fft_filter(pad(midi_hz(tones[0]), s.bar * 1.0), low=1800), b * 4, -0.4, 0.22)
        s.add(fft_filter(pad(midi_hz(tones[0] + 7), s.bar * 1.0), low=1800), b * 4, 0.4, 0.2)
        # Lightning: stabbed fifths, high and bright, on the offbeats.
        for k in (1.5, 3.5):
            for m in (tones[0] + 24, tones[0] + 31):
                s.add(pluck(midi_hz(m), s.beat * 0.3, bright=4200), b * 4 + k, rng.uniform(-0.6, 0.6), 0.2)
        s.add(kick(0.25), b * 4, 0, 0.9)
        s.add(kick(0.25), b * 4 + 1.5, 0, 0.8)
        s.add(kick(0.25), b * 4 + 2, 0, 0.9)
        s.add(snare(rng), b * 4 + 1, 0.1, 0.6)
        s.add(snare(rng), b * 4 + 3, 0.1, 0.6)
        if b % 2 == 1:
            for k in range(6):
                s.add(kick(0.5) * (0.3 + 0.08 * k), b * 4 + 2.5 + k * 0.25, rng.uniform(-0.3, 0.3), 0.7)
        for k in range(8):
            s.add(hat(rng, 0.04), b * 4 + k * 0.5 + 0.25, 0.5, 0.18)
    melody(s, rng, root, scale, prog, bell, start_bar=2, octave=24, pan=-0.2, gain=0.5, density=0.6)
    return s.render(reverb=0.4)


def track_dartmoor():
    """Dartmoor: the drowned dwarf capital. A slow dirge in D phrygian at 70, deep
    hall pads and an octave bass like a dwarf choir under water, a low bell tolling
    each bar, and crystal chimes ringing high and far apart, as if the meteor's
    shards were humming in the dark."""
    rng = np.random.default_rng(163)
    s = Song(bpm=70, bars=16)
    root, scale = 50, SCALES["phrygian"]
    prog = [0, 1, 0, 6, 5, 1, 0, 0] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(fft_filter(pad(midi_hz(m - 12), s.bar * 1.1), low=900), b * 4, rng.uniform(-0.5, 0.5), 0.42)
        low = scale_note(root - 24, scale, deg)
        s.add(bass(midi_hz(low), s.beat * 3.6), b * 4, 0, 0.6)
        s.add(bass(midi_hz(low + 12), s.beat * 1.6), b * 4 + 2, 0, 0.3)
        # The toll: a low bell on the downbeat.
        s.add(fft_filter(bell(midi_hz(root - 12), s.beat * 3.0), low=1800), b * 4, -0.15, 0.3)
        # Crystal chimes, high and sparse.
        for k in range(rng.integers(0, 3)):
            m = tones[rng.integers(0, 3)] + 24
            s.add(pluck(midi_hz(m), s.beat * 1.2, bright=5200), b * 4 + rng.integers(0, 8) * 0.5 + 0.25,
                  rng.uniform(-0.8, 0.8), 0.12)
        if b % 2 == 1:
            s.add(kick(0.5) * 0.4, b * 4 + 3, 0, 0.8)
    melody(s, rng, root, scale, prog, bell, start_bar=4, octave=12, pan=0.2, gain=0.42, density=0.3)
    return s.render(reverb=0.75)


def track_grieve():
    """King Grieve, the Drowned Sovereign: the Dartmoor dirge risen into a duel.
    D phrygian at 112, a heavy march: a dwarf-choir pad and octave bass on every
    beat, war drums and a tolling bell on the downbeat, crystal stabs on the
    offbeats like shards bursting, and the bell lead carrying a grave, regal line."""
    rng = np.random.default_rng(1871)
    s = Song(bpm=112, bars=16)
    root, scale = 50, SCALES["phrygian"]
    prog = [0, 1, 0, 6, 5, 1, 6, 0] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            s.add(fft_filter(pad(midi_hz(m - 12), s.bar * 1.05), low=1100), b * 4, rng.uniform(-0.5, 0.5), 0.3)
        low = scale_note(root - 24, scale, deg)
        for k in range(4):
            s.add(bass(midi_hz(low + (12 if k == 2 else 0)), s.beat * 0.8), b * 4 + k, 0, 0.55)
        s.add(fft_filter(bell(midi_hz(root - 12), s.beat * 2.5), low=1800), b * 4, -0.15, 0.32)
        # War drums: a march, with a roll into every fourth bar.
        s.add(kick(0.4), b * 4, 0, 1.0)
        s.add(kick(0.3), b * 4 + 2, 0, 0.8)
        s.add(snare(rng), b * 4 + 1, 0.1, 0.5)
        s.add(snare(rng), b * 4 + 3, 0.1, 0.5)
        if b % 4 == 3:
            for k in range(8):
                s.add(snare(rng) * (0.3 + 0.07 * k), b * 4 + 2 + k * 0.25, rng.uniform(-0.3, 0.3), 0.5)
        # Shards: high crystal stabs on the offbeats.
        for k in (0.5, 2.5):
            m = tones[rng.integers(0, 3)] + 24
            s.add(pluck(midi_hz(m), s.beat * 0.4, bright=5200), b * 4 + k, rng.uniform(-0.7, 0.7), 0.16)
    melody(s, rng, root, scale, prog, bell, start_bar=2, octave=12, pan=0.2, gain=0.5, density=0.5)
    return s.render(reverb=0.6)


class _Mirror:
    """Wraps a Song so every note is answered three-quarters of a beat later,
    softer and from the other side: the shadow's echo."""

    def __init__(self, song, lag=0.75):
        self.song, self.lag = song, lag
        self.beats, self.beat = song.beats, song.beat

    def add(self, note, at_beats, pan=0.0, gain=1.0):
        self.song.add(note, at_beats, pan, gain)
        self.song.add(note, at_beats + self.lag, -pan, gain * 0.55)


def track_eura():
    """Shadow Eura, the Mirror: the hero's own theme turned dark. E minor at 132,
    swelling reversed pads (sound drawn backwards out of the glass), a driving
    octave bass, tight hats, and a lead whose every note is echoed a beat late
    from the other side, the way the shadow answers each of your swings."""
    rng = np.random.default_rng(1874)
    s = Song(bpm=132, bars=16)
    root, scale = 52, SCALES["minor"]
    prog = [0, 5, 3, 6, 0, 5, 1, 4] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            # A pad played backwards: it swells up to the barline instead of fading.
            s.add(fft_filter(pad(midi_hz(m - 12), s.bar)[::-1], low=1400), b * 4, rng.uniform(-0.6, 0.6), 0.26)
        low = scale_note(root - 24, scale, deg)
        for k in range(8):
            s.add(bass(midi_hz(low + (12 if k % 2 else 0)), s.beat * 0.45), b * 4 + k * 0.5, 0, 0.42)
        s.add(kick(0.3), b * 4, 0, 0.9)
        s.add(kick(0.25), b * 4 + 2.5, 0, 0.7)
        s.add(snare(rng), b * 4 + 1, 0.1, 0.45)
        s.add(snare(rng), b * 4 + 3, 0.1, 0.45)
        for k in range(8):
            s.add(hat(rng), b * 4 + k * 0.5, rng.uniform(-0.4, 0.4), 0.18 if k % 2 else 0.1)
    melody(_Mirror(s), rng, root, scale, prog, lead, start_bar=2, octave=12, pan=0.35, gain=0.42, density=0.55)
    return s.render(reverb=0.45)


def track_zenis():
    """Zenis, inside the meteor: no tune the Tree would know. B locrian at 84 over a
    heartbeat (two kicks, a rest), a throbbing low pulse, pads detuned against each
    other so they beat and shimmer, and a far bell picking out the tritone, the
    sound of something alive and wrong."""
    rng = np.random.default_rng(177)
    s = Song(bpm=84, bars=16)
    root, scale = 47, SCALES["locrian"]
    prog = [0, 0, 4, 0, 5, 0, 4, 1] * 2
    for b, deg in enumerate(prog):
        tones = chord_tones(root, scale, deg)
        for m in tones:
            for cents in (-14, 14):
                f = midi_hz(m - 12) * 2 ** (cents / 1200)
                s.add(fft_filter(pad(f, s.bar * 1.1), low=1000), b * 4, 0.6 if cents > 0 else -0.6, 0.22)
        low = scale_note(root - 24, scale, deg)
        for k in range(8):
            s.add(bass(midi_hz(low), s.beat * 0.4) * (1.0 if k % 2 == 0 else 0.5), b * 4 + k * 0.5, 0, 0.35)
        # The heartbeat.
        for at in (0, 0.45, 2, 2.45):
            s.add(kick(0.35), b * 4 + at, 0, 0.75 if at in (0, 2) else 0.5)
        if b % 2 == 1:
            s.add(fft_filter(bell(midi_hz(root + 6), s.beat * 3.0), low=2400), b * 4 + 3, rng.uniform(-0.6, 0.6), 0.18)
    melody(s, rng, root, scale, prog, bell, start_bar=4, octave=24, pan=-0.3, gain=0.22, density=0.25)
    return s.render(reverb=0.7)


def track_evil_one():
    """The Evil One's avatar on its throne: the Zenis heartbeat quickened into a
    march. B locrian at 120, a pounding double-kick heartbeat, a bass that drops
    a tritone every other bar, detuned pads that beat against each other, and a
    low bell answering a cold lead, the meteor singing through a borrowed body."""
    rng = np.random.default_rng(1986)
    s = Song(bpm=120, bars=16)
    root, scale = 47, SCALES["locrian"]
    prog = [0, 4, 0, 5, 0, 4, 1, 4] * 2
    for b, deg in enumerate(prog):
        for m in chord_tones(root, scale, deg):
            for cents in (-18, 18):
                f = midi_hz(m - 12) * 2 ** (cents / 1200)
                s.add(fft_filter(pad(f, s.bar), low=1600), b * 4, 0.6 if cents > 0 else -0.6, 0.2)
        low = scale_note(root - 24, scale, deg) - (6 if b % 2 else 0)
        for k in range(8):
            s.add(bass(midi_hz(low + (12 if k in (3, 7) else 0)), s.beat * 0.45), b * 4 + k * 0.5, 0, 0.45)
        for at in (0, 0.35, 2, 2.35):
            s.add(kick(0.3), b * 4 + at, 0, 0.9 if at in (0, 2) else 0.6)
        s.add(snare(rng), b * 4 + 1, 0.1, 0.4)
        s.add(snare(rng), b * 4 + 3, 0.1, 0.4)
        for k in range(8):
            s.add(hat(rng), b * 4 + k * 0.5, rng.uniform(-0.4, 0.4), 0.14 if k % 2 else 0.08)
        if b % 4 == 3:
            s.add(fft_filter(bell(midi_hz(root - 6), s.beat * 3.0), low=1800), b * 4 + 2, -0.3, 0.3)
    melody(s, rng, root, scale, prog, lead, start_bar=2, octave=12, pan=0.25, gain=0.36, density=0.5)
    return s.render(reverb=0.55)


def amb_zenis():
    """The meteor's insides: a deep living drone that swells and ebbs like breath,
    a slow heartbeat under everything, and now and then a glassy whine as light
    moves through the veins."""
    rng = np.random.default_rng(178)
    dur = 24.0
    n = int(dur * RATE)
    m = n + RATE * 3
    out = np.zeros((m, 2))
    t = np.arange(m) / RATE
    breath = 0.6 + 0.4 * np.sin(2 * np.pi * t / 6.0)
    drone = fft_filter(rng.uniform(-1, 1, m), low=160, high=30) * 1.6 * breath
    out[:, 0] += drone
    out[:, 1] += np.roll(drone, RATE // 4)
    beat = np.zeros(m)
    for k in range(int(dur / 1.5)):
        for off in (0.0, 0.32):
            i = int((k * 1.5 + off) * RATE)
            tt = np.arange(int(0.25 * RATE)) / RATE
            thump = np.sin(2 * np.pi * 48 * tt) * np.exp(-tt * 18) * (0.35 if off == 0 else 0.22)
            beat[i:i + len(thump)] += thump
    out[:, 0] += beat
    out[:, 1] += beat
    pos = 1.5
    while pos < dur:
        i = int(pos * RATE)
        mm = int(1.6 * RATE)
        tt = np.arange(mm) / RATE
        f = rng.uniform(1400, 2600)
        whine = np.sin(2 * np.pi * f * tt * (1 + tt * 0.08)) * np.sin(np.pi * tt / 1.6) * rng.uniform(0.02, 0.04)
        pan = rng.uniform(-0.8, 0.8)
        end = min(i + mm, m)
        out[i:end, 0] += whine[: end - i] * (1 - pan) / 2
        out[i:end, 1] += whine[: end - i] * (1 + pan) / 2
        pos += rng.uniform(3.0, 6.0)
    loop = out[:n].copy()
    loop[: m - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.5


def amb_dartmoor():
    """A drowned hall: a deep, still drone of water in stone, drops falling into
    pools at uneven intervals, a slow trickle somewhere, and the faint glassy hum
    of meteor crystal rising and falling."""
    rng = np.random.default_rng(167)
    dur = 26.0
    n = int(dur * RATE)
    m = n + RATE * 3
    out = np.zeros((m, 2))
    t = np.arange(m) / RATE
    drone = fft_filter(rng.uniform(-1, 1, m), low=220, high=40) * 1.8
    out[:, 0] += drone
    out[:, 1] += np.roll(drone, RATE // 3)
    trickle = fft_filter(rng.uniform(-1, 1, m), low=5000, high=1500) * 0.12 * (0.6 + 0.4 * np.sin(2 * np.pi * t / 5.3))
    out[:, 0] += trickle * 0.4
    out[:, 1] += trickle
    hum = (np.sin(2 * np.pi * 880 * t) + 0.5 * np.sin(2 * np.pi * 1318.5 * t)) * 0.025 * (0.5 + 0.5 * np.sin(2 * np.pi * t / 11.0))
    out[:, 0] += hum
    out[:, 1] += hum
    # Drops: a short pitched plink and its echo.
    pos = 0.6
    while pos < dur:
        i = int(pos * RATE)
        mm = int(0.5 * RATE)
        tt = np.arange(mm) / RATE
        f = rng.uniform(900, 1700)
        drop = np.sin(2 * np.pi * f * tt * (1 + tt * 2.5)) * np.exp(-tt * 22) * rng.uniform(0.25, 0.5)
        pan = rng.uniform(-0.8, 0.8)
        for d, g in ((0, 1.0), (int(0.23 * RATE), 0.3)):
            j = i + d
            if j + mm < m:
                out[j:j + mm, 0] += drop * g * (1 - pan) / 2
                out[j:j + mm, 1] += drop * g * (1 + pan) / 2
        pos += rng.uniform(0.7, 2.6)
    loop = out[:n].copy()
    loop[: m - n] += out[n:]
    return loop / (np.max(np.abs(loop)) + 1e-9) * 0.5


TRACKS = {
    "title": track_title,
    "eolis": track_eolis,
    "trunk": track_trunk,
    "tower": track_tower,
    "boss": track_boss,
    "miniboss": track_miniboss,
    "zoradohna": track_zoradohna,
    "ripasheiku": track_ripasheiku,
    "zorugeriru": track_zorugeriru,
    "forepaw": track_forepaw,
    "mist": track_mist,
    "branches": track_branches,
    "conflate": track_conflate,
    "pakukame": track_pakukame,
    "borabohra": track_borabohra,
    "grieve": track_grieve,
    "eura": track_eura,
    "zenis": track_zenis,
    "evil_one": track_evil_one,
    "amb_zenis": amb_zenis,
    "dartmoor": track_dartmoor,
    "daybreak": track_daybreak,
    "daybreak_town": track_daybreak_town,
    "amb_trunk": amb_trunk,
    "amb_eolis": amb_eolis,
    "amb_tower": amb_tower,
    "amb_heights": amb_heights,
    "amb_mine": amb_mine,
    "amb_mist": amb_mist,
    "amb_branches": amb_branches,
    "amb_daybreak": amb_daybreak,
    "amb_dartmoor": amb_dartmoor,
}


def main():
    names = sys.argv[1:] or list(TRACKS)
    for name in names:
        write_ogg(name, TRACKS[name]())
        print("wrote", name)


if __name__ == "__main__":
    main()
