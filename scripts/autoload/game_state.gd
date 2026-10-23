extends Node
## Everything that persists between rooms and across saves: abilities, stats,
## gold, collected items, visited rooms, world flags and the save point.
## Rooms and the player read from it. Saves are JSON files in user://.

## Big centered banner (item get, area names). `subtitle` may be empty.
signal banner(title: String, subtitle: String)
## Small line of text near the bottom of the screen ("Progress saved").
signal toast(text: String)
## Asks the HUD to show a dialog box; it freezes the player until closed.
signal dialog_requested(speaker: String, pages: Array)

const SAVE_PATH := "user://save_%d.json"
const VERSION := 1

## Persistent game data. Keys are documented in `fresh()`.
var data := {}
var slot := 1
## Seconds played since the last save (added to data.play_time on save).
var play_time := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	data = fresh()


func _process(delta: float) -> void:
	play_time += delta


static func fresh() -> Dictionary:
	return {
		"version": VERSION,
		"abilities": {"glove": false, "mattock": false, "boots": false, "stride": false, "deluge": false},
		"max_hp": 100,
		"max_mp": 60.0,
		"flask_max": 2,
		"gold": 0,
		"xp": 0,
		"rank": 0,
		"skill_points": 0,
		"skills": [],
		"keys": {},
		"potion_shards": 0,
		"mantra_shards": 0,
		"collected": {},
		"visited": {},
		"flags": {},
		"purse": {},
		"save_room": "",
		"save_pos": [0, 0],
		"play_time": 0.0,
	}


func new_game() -> void:
	data = fresh()
	play_time = 0.0


# --- Queries ---------------------------------------------------------------------

func has_ability(id: String) -> bool:
	return bool(data.abilities.get(id, false))


func is_collected(id: String) -> bool:
	return data.collected.has(id)


func collect(id: String) -> void:
	data.collected[id] = true


func flag(id: String) -> bool:
	return bool(data.flags.get(id, false))


func set_flag(id: String, value := true) -> void:
	data.flags[id] = value


func visit(room_id: String) -> void:
	data.visited[room_id] = true


func is_visited(room_id: String) -> bool:
	return data.visited.has(room_id)


func key_count(kind: String) -> int:
	return int(data.keys.get(kind, 0))


func add_key(kind: String, n := 1) -> void:
	data.keys[kind] = key_count(kind) + n


func say(speaker: String, pages: Array) -> void:
	dialog_requested.emit(speaker, pages)


# --- Player sync -------------------------------------------------------------------

## Copies persistent stats onto a freshly spawned player.
func apply(p: Player) -> void:
	for k: String in data.abilities:
		p.abilities[k] = bool(data.abilities[k])
	p.max_hp = int(data.max_hp)
	p.hp = p.max_hp
	p.max_mp = float(data.max_mp)
	p.mp = p.max_mp
	p.flask_max = int(data.flask_max)
	p.flask_charges = p.flask_max
	p.gold = int(data.gold)


## Copies the player's live stats back (before saving or changing rooms).
func capture(p: Player) -> void:
	for k: String in p.abilities:
		data.abilities[k] = bool(p.abilities[k])
	data.max_hp = p.max_hp
	data.max_mp = p.max_mp
	data.flask_max = p.flask_max
	data.gold = p.gold


# --- Save files --------------------------------------------------------------------

func save_game(to_slot := -1) -> bool:
	if to_slot >= 0:
		slot = to_slot
	data.play_time = float(data.get("play_time", 0.0)) + play_time
	play_time = 0.0
	var f := FileAccess.open(SAVE_PATH % slot, FileAccess.WRITE)
	if f == null:
		push_warning("Could not write save slot %d" % slot)
		return false
	f.store_string(JSON.stringify(data, "\t"))
	return true


func has_save(which: int) -> bool:
	return FileAccess.file_exists(SAVE_PATH % which)


func load_game(from_slot: int) -> bool:
	if not has_save(from_slot):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH % from_slot))
	if not parsed is Dictionary:
		push_warning("Save slot %d is corrupt" % from_slot)
		return false
	# Start from fresh data so saves from older versions gain new keys.
	var loaded := fresh()
	var src: Dictionary = parsed
	for k: String in src:
		if loaded.has(k) and loaded[k] is Dictionary and src[k] is Dictionary:
			loaded[k].merge(src[k], true)
		else:
			loaded[k] = src[k]
	data = loaded
	slot = from_slot
	play_time = 0.0
	return true


func delete_save(which: int) -> void:
	if has_save(which):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH % which))
