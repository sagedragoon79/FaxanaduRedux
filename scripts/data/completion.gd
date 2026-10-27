class_name Completion
extends RefCounted
## How much of the world a save has seen (design bible 9, the completion card
## after the credits): rooms visited, hidden rooms found, treasures taken and
## bosses beaten, each against the whole game, and their average as one percent.


## Tallies the save in GameState against a World catalog (World.catalog).
static func tally(catalog: Dictionary) -> Dictionary:
	var rooms := 0
	var secrets := 0
	var secrets_total := 0
	var treasures := 0
	var treasures_total := 0
	for room_id: String in catalog:
		var info: Dictionary = catalog[room_id]
		if GameState.is_visited(room_id):
			rooms += 1
		if info.get("secret", false):
			secrets_total += 1
			if GameState.flag("secret:" + room_id):
				secrets += 1
		for id: String in info.get("treasures", []):
			treasures_total += 1
			if GameState.is_collected(id):
				treasures += 1
	var bosses := 0
	for id: String in BossArena.BOSSES:
		if GameState.flag("boss:" + id):
			bosses += 1
	var out := {
		"rooms": rooms, "rooms_total": catalog.size(),
		"secrets": secrets, "secrets_total": secrets_total,
		"treasures": treasures, "treasures_total": treasures_total,
		"bosses": bosses, "bosses_total": BossArena.BOSSES.size(),
	}
	out.percent = percent(out)
	return out


## Every guardian in the order the climb meets them, with the name the
## Journey page gives it (the mini-bosses among them).
const GUARDIANS := [
	["rokusutahn", "Rokusutahn"], ["foreman", "The Foreman"], ["zoradohna", "Zoradohna"],
	["ripasheiku", "Ripasheiku"], ["hag_matriarch", "The Marsh Hag Matriarch"], ["zorugeriru", "Zorugeriru"], ["pakukame", "Pakukame"],
	["bark_captain", "The Bark Knight Captain"], ["borabohra", "Borabohra"], ["king_grieve", "King Grieve"],
	["clockwork_alpha", "The Clockwork Alpha"], ["shadow_eura", "Shadow Eura"], ["drowned_warden", "The Drowned Warden"],
	["evil_avatar", "The Evil One, on the throne"], ["evil_veins", "The Evil One, in the veins"],
	["evil_one", "The Evil One, at the heart"],
]


## The guardians whose arenas the save has entered, in climb order:
## [{id, name, room, beaten}]. Arenas not yet found stay off the list, so the
## page never names a fight before you have seen its door.
static func guardians_found(catalog: Dictionary) -> Array:
	var rooms := {}
	for room_id: String in catalog:
		var b: String = catalog[room_id].get("boss", "")
		if b != "":
			rooms[b] = room_id
	var out := []
	for g: Array in GUARDIANS:
		var room: String = rooms.get(g[0], "")
		if room != "" and GameState.is_visited(room):
			out.append({"id": g[0], "name": g[1], "room": room, "beaten": GameState.flag("boss:" + g[0])})
	return out


## The Journey page's rows (pause menu): the four shares and the percent,
## then each guardian found, beaten or still waiting.
static func journey_rows(stats: Dictionary, found: Array) -> Array:
	var share := func(label: String, key: String, detail: String) -> Dictionary:
		var n := int(stats.get(key, 0))
		var total := int(stats.get(key + "_total", 0))
		return {"label": label, "right": "%d / %d" % [n, total], "detail": detail}
	var out := [
		{"label": "Of the world", "right": "%d%%" % int(stats.get("percent", 0)),
			"detail": "The whole world seen earns the Lord's Gold at Ilse's Dyeworks, and opens the Guru's rush."},
		share.call("Rooms explored", "rooms", "Every room on the Tree, the hidden ones too."),
		share.call("Hidden rooms", "secrets", "Rooms behind false walls. The Black Onyx shows their seams."),
		share.call("Treasures", "treasures", "Chests and finds that lie in the rooms. Treasure Sense marks the map."),
		share.call("Guardians beaten", "bosses", "The great foes and their lesser kin, each in an arena of its own."),
	]
	if not found.is_empty():
		out.append({"label": "Guardians found", "header": true})
	for g: Dictionary in found:
		out.append({"label": g.name, "right": "Beaten" if g.beaten else "Waits",
			"detail": "Fallen. Its arena is quiet now." if g.beaten else "Still waiting in its arena."})
	var hidden := int(stats.get("bosses_total", 0)) - found.size()
	if hidden > 0:
		out.append({"label": "%d not yet found" % hidden, "detail": "Some guardians wait off the road you have walked.", "enabled": false})
	return out


## The average of the four shares, rounded down: 100 only when all are whole.
static func percent(stats: Dictionary) -> int:
	var sum := 0.0
	var parts := 0
	for k: String in ["rooms", "secrets", "treasures", "bosses"]:
		var total := int(stats.get(k + "_total", 0))
		if total > 0:
			sum += float(stats.get(k, 0)) / total
			parts += 1
	return int(floor(sum / parts * 100.0 + 0.0001)) if parts > 0 else 0


## The whole world seen (100%): the "lord" flag puts the Lord's Gold on the
## shelf at Ilse's Dyeworks, the cloak's glow (design bible 11). True if earned.
static func award(stats: Dictionary) -> bool:
	if int(stats.get("percent", 0)) < 100:
		return false
	GameState.set_flag("lord")
	return true
