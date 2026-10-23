extends Node
## Everything that persists between rooms and across saves: abilities, stats,
## gold, collected items, visited rooms, world flags and the save point.
## Rooms and the player read from it. Saves are JSON files in user://.

## Big centered banner (item get, area names). `subtitle` may be empty.
signal banner(title: String, subtitle: String)
## Small line of text near the bottom of the screen ("Progress saved").
signal toast(text: String)
## A full-screen white flash (boss kills); strength 0 to 1.
signal flash(strength: float)
## Asks the HUD to show a dialog box; it freezes the player until closed.
signal dialog_requested(speaker: String, pages: Array)

const SAVE_PATH := "user://save_%d.json"
const VERSION := 1

## The original's 16 ranks. Each rank after Novice gives a skill point.
const RANKS := ["Novice", "Aspirant", "Battler", "Fighter", "Adept", "Chevalier", "Veteran", "Warrior",
	"Swordman", "Hero", "Soldier", "Myrmidon", "Champion", "Superhero", "Paladin", "Lord"]
const RANK_XP := [0, 40, 100, 180, 300, 460, 660, 900, 1200, 1560, 2000, 2500, 3100, 3800, 4600, 5500]
const LIFE_FRUIT_HP := 10
const MANA_DEW_MP := 10.0
const RESPEC_BASE := 200
const RESPEC_MAX := 2000

## Persistent game data. Keys are documented in `fresh()`.
var data := {}
var slot := 1
## False in the gym: kills there give no XP and nothing is recorded.
var active := true
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
		"respecs": 0,
		"equipment": {"blade": "hand_dagger", "armor": "", "shield": ""},
		"keys": {},
		"rings": [],
		"potion_shards": 0,
		"mantra_shards": 0,
		## Elixirs carried (at most Shop.ELIXIR_MAX): one revives the player in place on death.
		"elixirs": 0,
		## Ointments carried (at most Shop.OINTMENT_MAX).
		"ointments": 0,
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


func has_skill(id: String) -> bool:
	return id in data.skills


func rank_name() -> String:
	return RANKS[int(data.rank)]


## XP needed for the next rank, or -1 at Lord.
func next_rank_xp() -> int:
	var r := int(data.rank)
	return RANK_XP[r + 1] if r + 1 < RANK_XP.size() else -1


func add_xp(amount: int) -> void:
	if not active or amount <= 0:
		return
	data.xp = int(data.xp) + amount
	while int(data.rank) + 1 < RANK_XP.size() and int(data.xp) >= RANK_XP[int(data.rank) + 1]:
		data.rank = int(data.rank) + 1
		data.skill_points = int(data.skill_points) + 1
		banner.emit("Rank up: " + rank_name(), "You gain a skill point. A Guru can teach you new skills.")
		Sfx.play("rank", 0.0)


func key_count(kind: String) -> int:
	return int(data.keys.get(kind, 0))


func add_key(kind: String, n := 1) -> void:
	data.keys[kind] = key_count(kind) + n


func say(speaker: String, pages: Array) -> void:
	dialog_requested.emit(speaker, pages)


# --- Player sync -------------------------------------------------------------------

## Copies persistent state onto a player in the tree and fills its health,
## magic and potions.
func apply(p: Player) -> void:
	for k: String in data.abilities:
		p.abilities[k] = bool(data.abilities[k])
	p.gold = int(data.gold)
	p.elixirs = int(data.elixirs)
	p.ointments = int(data.ointments)
	refresh_stats(p)
	p.restore()


## Recomputes the player's derived stats from base stats, gear and skills.
## Current health, magic and potions are clamped, not refilled.
func refresh_stats(p: Player) -> void:
	var eq: Dictionary = data.equipment
	var blade := GameData.item(eq.blade)
	if blade.is_empty():
		blade = GameData.item("hand_dagger")
	p.slash_damage = int(blade.slash)
	p.heavy_damage = int(blade.heavy)
	p.reach_bonus = float(blade.reach)
	p.defense = float(GameData.item(eq.armor).get("defense", 0.0))
	p.has_shield = eq.shield != ""
	p.guard_reduction = float(GameData.item(eq.shield).get("guard", p.combat.guard_reduction))
	p.melee_mult = 1.1 if has_skill("keen_edge") else 1.0
	p.ground_combo_length = 4 if has_skill("fourth_strike") else 3
	p.mp_hit_mult = 1.5 if has_skill("siphon") else 1.0
	p.gold_mult = 1.1 if has_skill("gold_sense") else 1.0
	p.magnet_mult = 1.6 if has_skill("gold_sense") else 1.0
	p.max_hp = int(data.max_hp)
	p.max_mp = float(data.max_mp) + (20.0 if has_skill("clear_mind") else 0.0)
	p.flask_max = int(data.flask_max) + (1 if has_skill("deep_pockets") else 0)
	p.hp = mini(p.hp, p.max_hp)
	p.mp = minf(p.mp, p.max_mp)
	p.flask_charges = mini(p.flask_charges, p.flask_max)
	p.health_changed.emit(p.hp, p.max_hp)


## Copies the player's live state back (before saving or changing rooms).
## Max stats live only here, so they are not copied back.
func capture(p: Player) -> void:
	for k: String in p.abilities:
		data.abilities[k] = bool(p.abilities[k])
	data.gold = p.gold
	data.elixirs = p.elixirs
	data.ointments = p.ointments


## Applies a permanent stat item (Life Fruit, Mana Dew, Potion Shard) and
## returns the line to show under its name.
func grant_stat_item(kind: String, p: Player) -> String:
	match kind:
		"life_fruit":
			data.max_hp = int(data.max_hp) + LIFE_FRUIT_HP
			refresh_stats(p)
			p.restore()
			return "Your health grows. Two fruits make a new mask."
		"mana_dew":
			data.max_mp = float(data.max_mp) + MANA_DEW_MP
			refresh_stats(p)
			p.mp = p.max_mp
			return "Your magic grows by %d." % int(MANA_DEW_MP)
		"potion_shard":
			data.potion_shards = int(data.potion_shards) + 1
			var n := int(data.potion_shards)
			if n % 3 == 0:
				data.flask_max = int(data.flask_max) + 1
				refresh_stats(p)
				p.flask_charges = p.flask_max
				return "Three shards fuse. Your flask holds one more Red Potion."
			return "%d of 3. Three fuse into a new potion charge." % (n % 3)
		"mantra_shard":
			data.mantra_shards = int(data.mantra_shards) + 1
			var n := int(data.mantra_shards)
			if n % 3 == 0:
				data.skill_points = int(data.skill_points) + 1
				return "The mantra is whole. You gain a skill point."
			return "%d of 3. Three complete a mantra." % (n % 3)
	return ""


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
