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
