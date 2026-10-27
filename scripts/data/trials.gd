class_name Trials
extends RefCounted
## The Guru Trials (design bible 3.1 and 10): pure platforming courses in the
## mantra-space, an abstract monochrome place the Guru of the Temple of Mantras
## opens for you. They unlock two by two as the springs are restored. A trial
## runs on a clock from the moment you arrive; hazards there cost time, never
## health (they set you back on your last footing). Reach the bell at the far
## end to clear it: the first clear gives a Mantra Shard, and every clear keeps
## your best time (`GameState.data.trials`, trial id -> seconds). Leave from the
## pause menu at any time; you return a step from the Guru either way.

## In order. `springs`: how many springs must flow before the trial opens.
## `mantra`: the mantra time (seconds); ring the bell within it and the trial
## dyes your cloak (`dye`, pass 164), worn again for nothing at Ilse's.
## `needs`: the abilities its course is built for (the Glove if not given);
## by its springs every one of them is in hand. A trial whose room isn't
## built yet isn't offered.
const LIST := [
	{"id": "walls", "mantra": 12, "dye": "slate_dye", "name": "Mantra of Walls", "room": "trials/walls", "springs": 1,
		"desc": "Three pillars over spikes, thorned on their far sides. Climb each from the ledge at its foot."},
	{"id": "edges", "mantra": 14, "dye": "coral_dye", "name": "Mantra of Edges", "room": "trials/edges", "springs": 1,
		"desc": "Narrow footholds over spikes. Leave every ledge as late as you dare."},
	{"id": "thorns", "mantra": 15, "dye": "thorn_dye", "name": "Mantra of Thorns", "room": "trials/thorns", "springs": 2, "needs": ["glove", "mattock"],
		"desc": "Spikes, and thorns in the air. Strike down on every one; never touch the ground."},
	{"id": "winds", "mantra": 14, "dye": "jade_dye", "name": "Mantra of Winds", "room": "trials/winds", "springs": 2, "needs": ["glove", "boots"],
		"desc": "Wind across the void. Ride it, climb out of it, and let go over the bell."},
	{"id": "stillness", "mantra": 32, "dye": "frost_dye", "name": "Mantra of Stillness", "room": "trials/stillness", "springs": 3, "needs": ["glove", "hourglass"],
		"desc": "Water that falls forever. Still it, climb it, and wait where it is dry."},
	{"id": "falling", "name": "Mantra of Falling", "room": "trials/falling", "springs": 3, "desc": ""},
]
## Where the trials are opened from: the Guru's menu offers them only here.
const TEMPLE := "eolis/guru_temple"

## The trial under way: {"id", "time", "back_room", "back_pos"}, or empty.
static var run := {}


## The trials that exist in this build, in order.
static func built() -> Array:
	return LIST.filter(func(t: Dictionary) -> bool: return World.room_exists(t.room))


static func find(id: String) -> Dictionary:
	for t: Dictionary in LIST:
		if t.id == id:
			return t
	return {}


static func springs_flowing() -> int:
	var n := 0
	for k: String in GameState.data.flags:
		if k.begins_with("spring:") and bool(GameState.data.flags[k]):
			n += 1
	return n


static func is_open(t: Dictionary) -> bool:
	return springs_flowing() >= int(t.springs)


## The names of what the course is built for that you don't yet have (pass 160:
## the springs can flow before the Wing Boots are found). The Guru keeps such a
## trial sealed and says what it wants.
static func missing(t: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for a: String in t.get("needs", ["glove"]):
		if not bool(GameState.data.abilities.get(a, false)):
			out.append(String(ItemPickup.INFO[a].title) if ItemPickup.INFO.has(a) else a.capitalize())
	return out


## Open, and you have all it is built for.
static func ready(t: Dictionary) -> bool:
	return is_open(t) and missing(t).is_empty()


static func cleared(id: String) -> bool:
	return GameState.data.trials.has(id)


## Best time in seconds, or INF if never cleared.
static func best(id: String) -> float:
	return float(GameState.data.trials.get(id, INF))


static func active() -> bool:
	return not run.is_empty()


static func begin(id: String, back_room: String, back_pos: Vector2) -> void:
	run = {"id": id, "time": 0.0, "back_room": back_room, "back_pos": back_pos}


static func tick(delta: float) -> void:
	if active():
		run.time = float(run.time) + delta


## Ends the run at the bell. Returns {"time", "best", "first", "record", "dye"}
## ("dye": the cloak dye this run earned, "" if none).
static func finish() -> Dictionary:
	if not active():
		return {}
	var id: String = run.id
	var t: float = run.time
	var first := not cleared(id)
	var old := best(id)
	var record := t < old
	if record:
		GameState.data.trials[id] = snappedf(t, 0.01)
	if first:
		GameState.grant_stat_item("mantra_shard", null)
	var dye := ""
	var trial := find(id)
	if not trial.is_empty() and trial.has("mantra") and t <= float(trial.mantra) and not GameState.owns_dye(String(trial.dye)):
		dye = String(trial.dye)
		GameState.earn_dye(dye)
	return {"time": t, "best": minf(t, old), "first": first, "record": record, "dye": dye}


static func abandon() -> void:
	run = {}


## Where to set the player down in a trial room: its `P` marker.
static func start_pos(room_text: String) -> Vector2:
	var grid := room_text.split("---", true, 1)
	var rows := grid[1].strip_edges(true, false).split("\n") if grid.size() > 1 else PackedStringArray()
	for y in rows.size():
		var x := rows[y].find("P")
		if x >= 0:
			return Vector2(x * Room.TILE + Room.TILE * 0.5, (y + 1) * Room.TILE)
	return Vector2.ZERO


## "0:23.4"
static func format_time(t: float) -> String:
	if t == INF:
		return "--"
	var tenths := int(floor(t * 10.0))
	return "%d:%02d.%d" % [tenths / 600, (tenths / 10) % 60, tenths % 10]
