#!/usr/bin/env python3
"""One-time rename of the internal ids that still carried the source game's words
(pass 462). Pass 461 renamed every name the player sees; this pass renames what
only the code sees: zone folders, room ids, item, ability, npc, boss and flag
ids, script and asset file names. The table is `ids` in data/rename_map.json,
which the game also reads to bring old saves over (GameState.migrate_ids).

Words that are also plain English (mist, trunk, guru...) are renamed only where
they are ids: in code, in a string with no spaces, or joined to another word by
`_`, `/`, `:` or `.`. Prose, comments and old pass notes keep their words.

Run from the repo root: python3 tools/rename/ids.py [--dry]
"""
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(ROOT)
TABLE = json.load(open("data/rename_map.json"))["ids"]
PAIRS: list = TABLE["segments"]
# Words that are not English: renamed in prose too.
UNIQUE = set(TABLE["unique"])

SKIP_PREFIX = ("docs/loop/", "tools/rename/", ".github/")
SKIP_FILES = {"data/rename_map.json"}
TEXT_EXT = {".gd", ".py", ".json", ".import", ".md", ".uid", ".room", ".gdshader", ".yml", ".tscn",
            ".sh", ".csv", ".txt", ".cfg", ".godot", ".gpl", ".svg"}

_ALNUM = "A-Za-z0-9"


def _pat(old: str) -> re.Pattern:
    return re.compile(r"(?<![%s])%s(?![%s])" % (_ALNUM, re.escape(old), _ALNUM))


COMPILED = []
for old, new in sorted(PAIRS, key=lambda p: -len(p[0])):
    COMPILED.append((_pat(old), new, old))
    COMPILED.append((_pat(old.upper()), new.upper(), old.upper()))


def rename_id(s: str) -> str:
    """Every mapped word in an id (no prose here)."""
    for pat, new, _old in COMPILED:
        s = pat.sub(new, s)
    return s


TOKEN = re.compile(r"[A-Za-z0-9_]+")


def rename_prose(s: str) -> str:
    """Prose: rename a token only if it is joined to another word (an id or a path)
    or holds a word that is not English."""
    out = []
    last = 0
    for m in TOKEN.finditer(s):
        tok = m.group(0)
        before = s[m.start() - 1] if m.start() > 0 else ""
        after = s[m.end()] if m.end() < len(s) else ""
        joined = "_" in tok or before in "/:" or after in "/:" or (after == "." and m.end() + 1 < len(s) and s[m.end() + 1].isalpha() and s[m.end() + 1].islower())
        new = tok
        if joined:
            new = rename_id(tok)
        elif tok.lower() in UNIQUE:
            new = rename_id(tok)
        out.append(s[last:m.start()])
        out.append(new)
        last = m.end()
    out.append(s[last:])
    return "".join(out)


def rename_string(body: str) -> str:
    if body.strip() == "" or re.search(r"\s", body) is None:
        return rename_id(body)
    return rename_prose(body)


def rename_code(src: str, comment: str = "#", triple: bool = False) -> str:
    """Code is ids; strings with spaces and comments are prose."""
    out = []
    i = 0
    n = len(src)
    code_start = 0

    def flush_code(end):
        out.append(rename_id(src[code_start:end]))

    while i < n:
        c = src[i]
        if comment and src.startswith(comment, i):
            flush_code(i)
            j = src.find("\n", i)
            j = n if j < 0 else j
            out.append(rename_prose(src[i:j]))
            i = j
            code_start = i
            continue
        if c in "\"'":
            if triple and src.startswith(c * 3, i):
                flush_code(i)
                j = src.find(c * 3, i + 3)
                j = n if j < 0 else j + 3
                out.append(src[i:i + 3] + rename_prose(src[i + 3:j - 3]) + src[j - 3:j])
                i = j
                code_start = i
                continue
            flush_code(i)
            j = i + 1
            while j < n and src[j] != c and src[j] != "\n":
                if src[j] == "\\":
                    j += 1
                j += 1
            body = src[i + 1:j]
            out.append(c + rename_string(body) + (src[j] if j < n else ""))
            i = j + 1
            code_start = i
            continue
        i += 1
    flush_code(n)
    return "".join(out)


def rename_room(src: str) -> str:
    lines = []
    for line in src.split("\n"):
        m = re.match(r"^(name|sign):(.*)$", line)
        if m:
            lines.append(m.group(1) + ":" + rename_prose(m.group(2)))
        else:
            lines.append(rename_code(line))
    return "\n".join(lines)


def rename_markdown(src: str) -> str:
    out = []
    fence = False
    for line in src.split("\n"):
        if line.lstrip().startswith("```"):
            fence = not fence
            out.append(line)
            continue
        if fence:
            out.append(rename_code(line))
            continue
        parts = line.split("`")
        for k in range(len(parts)):
            parts[k] = rename_string(parts[k]) if k % 2 == 1 else rename_prose(parts[k])
        out.append("`".join(parts))
    return "\n".join(out)


def rename_text(path: str, src: str) -> str:
    ext = os.path.splitext(path)[1]
    if ext == ".room":
        return rename_room(src)
    if ext == ".md":
        return rename_markdown(src)
    if ext in (".gd", ".sh", ".yml", ".cfg", ".godot"):
        return rename_code(src)
    if ext == ".py":
        return rename_code(src, triple=True)
    if ext in (".json", ".import", ".tscn", ".uid", ".svg"):
        return rename_code(src, comment="")
    return rename_prose(src)


def new_path(path: str) -> str:
    return "/".join(rename_id(part) for part in path.split("/"))


def main() -> None:
    dry = "--dry" in sys.argv
    files = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True).stdout.split("\n")
    files = [f for f in files if f and os.path.exists(f)]
    existing = set(files)
    moves = {}
    for f in files:
        if f.startswith(SKIP_PREFIX) or f in SKIP_FILES:
            continue
        nf = new_path(f)
        if nf != f:
            if nf in existing or nf in moves.values():
                sys.exit("collision: %s -> %s" % (f, nf))
            moves[f] = nf
    edited = 0
    for f in files:
        if f.startswith(SKIP_PREFIX) or f in SKIP_FILES:
            continue
        if os.path.splitext(f)[1] not in TEXT_EXT:
            continue
        try:
            src = open(f, encoding="utf-8").read()
        except UnicodeDecodeError:
            continue
        dst = rename_text(f, src)
        if dst != src:
            edited += 1
            if not dry:
                open(f, "w", encoding="utf-8").write(dst)
    print("edited %d files, moving %d" % (edited, len(moves)))
    if dry:
        for f, nf in list(moves.items())[:40]:
            print(" ", f, "->", nf)
        return
    for f, nf in moves.items():
        os.makedirs(os.path.dirname(nf) or ".", exist_ok=True)
        subprocess.run(["git", "mv", f, nf], check=True)
    # Drop directories the moves left empty.
    for d, _sub, fs in sorted(os.walk("."), key=lambda t: -len(t[0])):
        if d.startswith("./.git") or d.startswith("./.godot"):
            continue
        if not os.listdir(d):
            os.rmdir(d)


if __name__ == "__main__":
    main()
