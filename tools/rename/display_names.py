"""The Yldenfall rename, step one: the names a player or a reader sees (2026-11-04).

The game was a Faxanadu remake until pass 460 and is now its own world (design bible 1
and 2). This rewrites the retired display names in the docs, data, rooms and in the string
literals and comments of the scripts and tests. Ids (lowercase, snake_case) are left for
step two. Run once from the repo root; it is kept as the record of what was renamed.

In code files only string literals and comments change. Lowercase words (meteor, guru,
mantra) change only in prose: markdown, comments, and strings that hold a space.
"""
from __future__ import annotations

import re
import subprocess
import sys

# Capitalized names, applied everywhere text may change. Longest and most specific first.
CAPS: list[tuple[str, str]] = [
	("Faxanadu Reborn", "Yldenfall"),
	("King of Eolis", "Reeve Aldous"),
	("Temple of Mantras", "Hall of Rings"),
	("Fraternal Castle", "Hall of Still Water"),
	("FRATERNAL CASTLE", "HALL OF STILL WATER"),
	("Guru Trials", "Inner Rings"),
	("Mantra Path", "Grain Road"),
	("Mantra Shards", "Grain Shards"),
	("Mantra Shard", "Grain Shard"),
	("Mantra Slate", "Grain Slate"),
	("Mantra of Death", "Deep Wither"),
	("Mantra of", "Ring of"),
	("Gurus", "Ringreaders"),
	("Guru's", "Ringreader's"),
	("Guru", "Ringreader"),
	("Mantras", "Rings"),
	("Mantra", "Ring"),
	("the World Tree", "the Ylden"),
	("The World Tree", "The Ylden"),
	("World Tree", "Ylden"),
	("Tower of Trunk", "Hollin Tower"),
	("Chart of the Trunk Hollows", "Chart of the Heartwood"),
	("Trunk Hollows", "Heartwood"),
	("Spring of the Trunk", "Heartwood Spring"),
	("Spring of Trunk", "Heartwood Spring"),
	("Spring of Mist", "Haar Spring"),
	("Spring of the Mist", "Haar Spring"),
	("Spring of Sky", "Sky Spring"),
	("Spring of the Sky", "Sky Spring"),
	("Branches (Daybreak) and Canopy Spires", "Storm Spires"),
	("Branches (Daybreak)", "Storm Spires"),
	("Branches (Conflate)", "High Boughs"),
	("Chart of the Branches", "Chart of the High Boughs"),
	("Chart of Daybreak", "Chart of the Storm Spires"),
	("the Branches", "the High Boughs"),
	("The Branches", "The High Boughs"),
	("Chart of the Mist", "Chart of the Haar"),
	("Mist Hydra", "Haar Wyrm"),
	("the Mist", "the Haar"),
	("The Mist", "The Haar"),
	("Throne of Zenis", "Throne of the Evercrown"),
	("Zenis Gate", "Crown Gate"),
	("Zenis gate", "Crown Gate"),
	("Heart of the Meteor", "Heart of the Bloom"),
	("Meteor Rise", "Glass Rise"),
	("Meteor Slug", "Glass Slug"),
	("Onyx Crypt", "Seer's Crypt"),
	("Victim Causeway", "Lampwick Causeway"),
	("Eolis of Old", "Old Hearthroot"),
	("King's Hall", "Reeve's Hall"),
	("King's Kennels", "Thane's Kennels"),
	("King's Stair", "Thane's Stair"),
	("King Grieve's", "Thane Vorrund's"),
	("King Grieve", "Thane Vorrund"),
	("KING GRIEVE", "THANE VORRUND"),
	("the Drowned Sovereign", "the Unweeping"),
	("Grieve", "Vorrund"),
	("Shadow Eura", "the Likeness"),
	("SHADOW EURA", "THE LIKENESS"),
	("The Evil One", "The Everbloom"),
	("the Evil One", "the Everbloom"),
	("THE EVIL ONE", "THE EVERBLOOM"),
	("Evil One", "Everbloom"),
	("Rokusutahn", "Gnarlmaw"),
	("ROKUSUTAHN", "GNARLMAW"),
	("Zoradohna", "Durgan"),
	("ZORADOHNA", "DURGAN"),
	("Ripasheiku", "Gloamweaver"),
	("RIPASHEIKU", "GLOAMWEAVER"),
	("Zorugeriru", "the Haar Wyrm"),
	("ZORUGERIRU", "THE HAAR WYRM"),
	("Pakukame", "Snapcrown"),
	("PAKUKAME", "SNAPCROWN"),
	("Borabohra", "Skyrend"),
	("BORABOHRA", "SKYREND"),
	("Bog Myconids", "Bog Puffcaps"),
	("Bog Myconid", "Bog Puffcap"),
	("Myconids", "Puffcaps"),
	("Myconid", "Puffcap"),
	("Monodrons", "Blinkhops"),
	("Monodron", "Blinkhop"),
	("Nagas", "Silt Adders"),
	("Naga", "Silt Adder"),
	("Liliths", "Mothlings"),
	("Lilith", "Mothling"),
	("Elf Ring", "Thaw Seed"),
	("Ruby Ring", "Sun Seed"),
	("Dworf Ring", "Fall Seed"),
	("Demon Ring", "Frost Seed"),
	("Dworf", "Hollin"),
	("Dragon Slayer", "Severance"),
	("DRAGON SLAYER", "SEVERANCE"),
	("Long Sword", "Wayfarer's Sword"),
	("Leather Armor", "Tanned Jerkin"),
	("Studded Mail", "Riveted Coat"),
	("Full Plate", "Knight's Plate"),
	("Battle Suit", "Elven Plate"),
	("Battle Helmet", "Elven Helm"),
	("Small Shield", "Buckler"),
	("Large Shield", "Kite Shield"),
	("Magic Shield", "Warding Shield"),
	("Jack Key", "Copper Key"),
	("Queen Key", "Silver Key"),
	("King Key", "Gold Key"),
	("Ace Key", "Thorn Key"),
	("Joker Key", "Glass Key"),
	("Jack", "Copper"),
	("Queen", "Silver"),
	("King door", "Gold door"),
	("King keys", "Gold keys"),
	("Ace", "Thorn"),
	("Joker", "Glass"),
	("Wing Boots", "Featherstep Boots"),
	("Mattock Mastery", "Pick Mastery"),
	("Mattock", "Delver's Pick"),
	("MATTOCK", "DELVER'S PICK"),
	("Hour Glass", "Stillstone"),
	("HOUR GLASS", "STILLSTONE"),
	("Black Onyx", "Seer's Lens"),
	("BLACK ONYX", "SEER'S LENS"),
	("Onyx", "Lens"),
	("Red Potion", "Sapflask"),
	("Elixirs", "Amber Draughts"),
	("Elixir", "Amber Draught"),
	("Ointment", "Barkbalm"),
	("Pendant", "Acorn Charm"),
	("Magical Rod", "Briar Wand"),
	("Poison", "Blightcap"),
	("Deluge Pierce", "Torrent Pierce"),
	("Deluge", "Torrent"),
	("DELUGE", "TORRENT"),
	("Chain Thunder", "Forked Storm"),
	("Tilte Swarm", "Wisp Swarm"),
	("Tilte", "Wisplight"),
	("TILTE", "WISPLIGHT"),
	("Trunk", "Heartwood"),
	("Eolis", "Hearthroot"),
	("EOLIS", "HEARTHROOT"),
	("Apolune", "Amberlee"),
	("APOLUNE", "AMBERLEE"),
	("Forepaw", "Kettleforge"),
	("FOREPAW", "KETTLEFORGE"),
	("Victim", "Lampwick"),
	("VICTIM", "LAMPWICK"),
	("Mascon", "Polesend"),
	("MASCON", "POLESEND"),
	("Conflate", "Sylvarre"),
	("CONFLATE", "SYLVARRE"),
	("Daybreak", "Carillon"),
	("DAYBREAK", "CARILLON"),
	("Dartmoor", "Vorrhallow"),
	("DARTMOOR", "VORRHALLOW"),
	("Zenis", "the Evercrown"),
	("ZENIS", "THE EVERCROWN"),
	("Branches", "High Boughs"),
	("Mist", "Haar"),
	("MIST", "HAAR"),
	("Meteor", "Stillglass"),
	("Faxanadu", "Yldenfall"),
	("FAXANADU", "YLDENFALL"),
]

# Lowercase words, applied only to prose.
LOWER: list[tuple[str, str]] = [
	("meteor crystals", "stillglass"),
	("meteor crystal", "stillglass"),
	("meteor-fortress", "bloom-fortress"),
	("meteor-fused", "glass-fused"),
	("meteor-born", "grief-born"),
	("the meteor's", "the Everbloom's"),
	("the meteor", "the Everbloom"),
	("meteor", "stillglass"),
	("gurus", "ringreaders"),
	("guru", "ringreader"),
	("mantra-space", "inner rings"),
	("mantras", "rings"),
	("mantra", "ring"),
	("dworf", "hollin"),
]

# The spells, ranks and kings that are also ordinary words: only these exact phrases.
PHRASES: list[tuple[str, str]] = [
	("Fire Scroll", "Kindle Scroll"),
	("Fire scroll", "Kindle scroll"),
	("Fire spell", "Kindle spell"),
	("Thunder Scroll", "Stormcall Scroll"),
	("Thunder scroll", "Stormcall scroll"),
	("Thunder spell", "Stormcall spell"),
	("Death spell", "Wither spell"),
]


def _compile(pairs: list[tuple[str, str]], ignore_case: bool = False) -> list[tuple[re.Pattern, str]]:
	out = []
	for old, new in pairs:
		pat = r"(?<![A-Za-z0-9_])" + re.escape(old) + r"(?![A-Za-z0-9_])"
		out.append((re.compile(pat), new))
	return out


CAPS_RE = _compile(CAPS)
LOWER_RE = _compile(LOWER)
PHRASE_RE = _compile(PHRASES)
# "the the Evercrown", "of the the Haar Wyrm" and the like after a name that brought its own article.
ARTICLES = [(re.compile(r"\b([Tt]he) the (Evercrown|Haar Wyrm|Likeness|Everbloom)\b"), r"\1 \2"),
	(re.compile(r"\b([Aa]) the Evercrown\b"), lambda m: ("An" if m.group(1) == "A" else "an") + " Evercrown"),
	(re.compile(r"\bHaar curtain"), "Mist curtain"),
	(re.compile(r"\bSilver, King\b"), "Silver, Gold"),
	(re.compile(r"\bKing \(900 g\)"), "Gold (900 g)"),
	(re.compile(r"(^|[.!?:\"] |\n\s*|\| )the (Evercrown|Haar Wyrm|Likeness|Haar|Heartwood|High Boughs|Ylden)"), r"\1The \2")]


def rename(text: str, prose: bool) -> str:
	for pat, new in PHRASE_RE:
		text = pat.sub(new, text)
	for pat, new in CAPS_RE:
		text = pat.sub(new, text)
	if prose:
		for pat, new in LOWER_RE:
			text = pat.sub(new, text)
	for pat, new in ARTICLES:
		text = pat.sub(new, text)
	return text


# GDScript and Python: change only string literals and comments.
TOKEN = re.compile(r'"""(?:.|\n)*?"""|\'\'\'(?:.|\n)*?\'\'\'|"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\'|#[^\n]*')


# Script class names spelled as strings (tests load classes by name); step two renames them.
CLASS_NAMES = {"Rokusutahn", "Zoradohna", "Ripasheiku", "Zorugeriru", "Pakukame", "Borabohra", "Monodron", "Naga",
	"Lilith", "BogMyconid", "KingGrieve", "ShadowEura", "MeteorSlug"}


def rename_code(text: str) -> str:
	def sub(m: re.Match) -> str:
		s = m.group(0)
		if s.startswith("#"):
			return rename(s, True)
		# A string holding a space is prose; a bare word may be an id, which waits for step two.
		if s.strip("\"'") in CLASS_NAMES:
			return s
		return rename(s, " " in s)
	return TOKEN.sub(sub, text)


CODE_SPAN = re.compile(r"(`[^`\n]*`)")


def rename_markdown(text: str) -> str:
	# Code spans may hold ids (`guru`, `eolis/east_gate`): only capitalized names change there.
	parts = CODE_SPAN.split(text)
	return "".join(rename(p, not p.startswith("`")) for p in parts)


def rename_room(text: str) -> str:
	# A room's header holds ids (npc, boss, doors); only its name and signs are prose.
	lines = text.split("\n")
	for i, line in enumerate(lines):
		lines[i] = rename(line, line.startswith(("name:", "sign:")))
	return "\n".join(lines)


def main() -> None:
	files = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True).stdout.split()
	skip_prefix = ("docs/loop/", "tools/rename/", "art/", ".github/")
	changed = 0
	for f in files:
		if f.startswith(skip_prefix) or f == "data/original_names.json":
			continue
		if f.endswith((".gd", ".py", ".json")):
			fn = rename_code
		elif f.endswith(".md"):
			fn = rename_markdown
		elif f.endswith(".room"):
			fn = rename_room
		elif f in ("project.godot", "export_presets.cfg"):
			fn = lambda t: rename(t, False)
		else:
			continue
		try:
			old = open(f, encoding="utf-8").read()
		except (UnicodeDecodeError, FileNotFoundError):
			continue
		new = fn(old)
		if new != old:
			open(f, "w", encoding="utf-8").write(new)
			changed += 1
	print(f"{changed} files changed", file=sys.stderr)


if __name__ == "__main__":
	main()
