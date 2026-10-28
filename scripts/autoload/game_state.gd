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
## The Evil One is dead: the game shows the ending (EndingScreen).
signal ending_started

const SAVE_PATH := "user://save_%d.json"
const VERSION := 1
## Item ids a newer build renamed: old id -> new id (sanitize carries a save over).
const RENAMED_ITEMS := {"hand_dagger": "short_sword", "giant_blade": "dwarvish_broad_sword"}
## Pickups a newer build moved: old id -> new id. A pickup's id is its room and
## cell, so a save that took it at the old cell would find it again (pass 213).
const MOVED_PICKUPS := {
	"dartmoor/drowned_nave:31,5": "dartmoor/drowned_nave:31,6",  # pass 67
	"branches/north_bough:8,7": "branches/north_bough:9,6",  # pass 211
}
## The equipment slots, in the order the Equipment page lists them.
const GEAR_SLOTS := ["blade", "armor", "shield", "helmet"]

## The original's 16 ranks. Each rank after Novice gives a skill point.
const RANKS := ["Novice", "Aspirant", "Battler", "Fighter", "Adept", "Chevalier", "Veteran", "Warrior",
	"Swordman", "Hero", "Soldier", "Myrmidon", "Champion", "Superhero", "Paladin", "Lord"]
## Damage each smith temper adds to a blade (design bible 5.2).
const TEMPER_BONUS := 0.15
const RANK_XP := [0, 40, 100, 180, 300, 460, 660, 900, 1200, 1560, 2000, 2500, 3100, 3800, 4600, 5500]
const LIFE_FRUIT_HP := 10
## Resilience (skill tree): one more mask.
const RESILIENCE_HP := 20
const MANA_DEW_MP := 10.0
const RESPEC_BASE := 200
const RESPEC_MAX := 2000

## Persistent game data. Keys are documented in `fresh()`.
## The original's password alphabet, more or less: letters, digits, ? and !.
const MANTRA_LETTERS := "ABCDEFGHJKLMNPQRSTUVWXYZabdefghkmnpqrtwy23456789?!"

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
		"abilities": {"glove": false, "mattock": false, "boots": false, "stride": false, "deluge": false, "fire": false, "thunder": false, "tilte": false, "onyx": false, "hourglass": false, "death": false, "rune_dagger": false, "pendant": false, "magical_rod": false},
		## The spell on the Spell button (an id in `Spells.ORDER`).
		"spell": "deluge",
		"max_hp": 100,
		"max_mp": 60.0,
		"flask_max": 2,
		"gold": 0,
		"xp": 0,
		"rank": 0,
		## The highest rank a Guru has named you by (Faxanadu's title ceremony).
		"named_rank": 0,
		"skill_points": 0,
		"skills": [],
		"respecs": 0,
		"equipment": {"blade": "short_sword", "armor": "", "shield": "", "helmet": ""},
		## Smith tempers per blade id (0 to 2): each adds TEMPER_BONUS to its damage.
		"tempers": {},
		"keys": {},
		"rings": [],
		"potion_shards": 0,
		"mantra_shards": 0,
		## Meteor Shards carried: the Forepaw smith folds one into each second temper.
		"meteor_shards": 0,
		## Elixirs carried (at most Shop.ELIXIR_MAX): one revives the player in place on death.
		"elixirs": 0,
		## Ointments carried (at most Shop.OINTMENT_MAX).
		"ointments": 0,
		"collected": {},
		"visited": {},
		## Room id -> [x, y] of each Guru you have spoken to: the Mantra Path's stops.
		"gurus": {},
		## Zones whose outline the Cartographer sold you (zone -> true): the map shows their unseen rooms dimmed.
		"charts": {},
		## Map pins: [room id, x, y] in room pixels (at most MAX_PINS).
		"pins": [],
		"flags": {},
		"purse": {},
		"save_room": "",
		"save_pos": [0, 0],
		"play_time": 0.0,
		## Times the game has been finished on this save (the ending sets the `cleared` flag too).
		"clears": 0,
		## Times you have fallen this run (the secret ending wants none).
		"deaths": 0,
		## Guru Trials cleared: trial id -> best time in seconds (Trials).
		"trials": {},
		## Cloak dyes bought at Ilse's Dyeworks (pass 136), and the one worn ("" is Warden Green).
		"dyes": [],
		## Every blade, armor, shield and helmet you have bought or found (pass 186):
		## the Equipment page swaps between them.
		"gear": ["short_sword"],
		"dye": "",
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


## The cloak dye worn: an item id from data/items.json (kind "dye").
func dye() -> String:
	var id := String(data.get("dye", ""))
	return id if id != "" else "warden_dye"


## Gives a dye won rather than bought (a Guru Trial's mantra time, pass 164):
## it goes on the cloak, and its flag puts it on Ilse's shelf to wear again.
func earn_dye(id: String) -> void:
	var owned: Array = data.get("dyes", [])
	if not owned.has(id):
		owned.append(id)
	data.dyes = owned
	data.dye = id
	set_flag("dye:" + id)


## Gear (pass 186): a blade, armor, shield or helmet you have is kept, and the
## Equipment page puts any of it on.
func owns_gear(id: String) -> bool:
	return Array(data.get("gear", [])).has(id) or GEAR_SLOTS.any(func(s: String) -> bool: return String(data.equipment.get(s, "")) == id)


## Takes `id` into your gear and puts it on (a purchase, a find, a reward).
func obtain_gear(id: String, p: Player = null) -> void:
	if not Array(data.gear).has(id):
		data.gear.append(id)
	var slot := String(GameData.item(id).get("kind", ""))
	if GEAR_SLOTS.has(slot):
		data.equipment[slot] = id
	if p != null:
		refresh_stats(p)


## Puts on gear you have, in its slot. Wearing what is already worn takes it
## off, except the blade: you always hold one.
func wear(id: String, p: Player = null) -> void:
	var slot := String(GameData.item(id).get("kind", ""))
	if not GEAR_SLOTS.has(slot) or not owns_gear(id):
		return
	if String(data.equipment.get(slot, "")) == id and slot != "blade":
		data.equipment[slot] = ""
	else:
		data.equipment[slot] = id
	if p != null:
		refresh_stats(p)


## True when the blade in hand takes both hands (the Dwarvish Broad Sword):
## the shield stays on your back, and you can't guard or parry.
func two_handed() -> bool:
	return bool(GameData.item(String(data.equipment.blade)).get("two_handed", false))


## Whether this save owns a dye. Warden Green is the cloak you start in, and
## the Lord's Gold is given, not sold.
func owns_dye(id: String) -> bool:
	return id == "warden_dye" or id == "lord_dye" or Array(data.get("dyes", [])).has(id)


## The Evil One is dead: mark the save cleared and start the ending.
func begin_ending() -> void:
	set_flag("cleared")
	if secret_ending():
		set_flag("cleared_secret")
	data.clears = int(data.get("clears", 0)) + 1
	ending_started.emit()


## Seconds played on this save, counting the time since the last save.
## The secret ending (design bible 11): the Evil One reached without a single
## death, wearing the Drowned Warden's Battle Suit.
func secret_ending() -> bool:
	return int(data.get("deaths", 0)) == 0 and String(data.equipment.get("armor", "")) == "battle_suit"


func total_play_time() -> float:
	return float(data.get("play_time", 0.0)) + play_time


## Map pins you may place at once (design bible 3.3).
const MAX_PINS := 12
## A pin this close to where you stand is the one a press removes.
const PIN_REACH := 48.0


func has_chart(zone: String) -> bool:
	return bool(data.charts.get(zone, false))


## Places a pin where you stand, or removes the one within PIN_REACH. Returns
## "placed", "removed" or "full".
func toggle_pin(room_id: String, pos: Vector2) -> String:
	for i in data.pins.size():
		var pin: Array = data.pins[i]
		if pin[0] == room_id and Vector2(float(pin[1]), float(pin[2])).distance_to(pos) < PIN_REACH:
			data.pins.remove_at(i)
			return "removed"
	if data.pins.size() >= MAX_PINS:
		return "full"
	data.pins.append([room_id, pos.x, pos.y])
	return "placed"


## The Mantra Path (design bible 3.3): Guru-to-Guru travel, open once any
## spring flows again.
func mantra_path_open() -> bool:
	for k: String in data.flags:
		if k.begins_with("spring:") and bool(data.flags[k]):
			return true
	return false


func meet_guru(room_id: String, pos: Vector2) -> void:
	data.gurus[room_id] = [pos.x, pos.y]


## The Gurus you could walk the Mantra Path to from `here` (room ids, sorted).
func mantra_stops(here: String) -> Array:
	var out := []
	for k: String in data.gurus:
		if k != here:
			out.append(k)
	out.sort()
	return out


func visit(room_id: String) -> void:
	data.visited[room_id] = true


func is_visited(room_id: String) -> bool:
	return data.visited.has(room_id)


func has_skill(id: String) -> bool:
	return id in data.skills


## The Guru's "mantra" for the journey so far: a nod to Faxanadu's password
## saves (design bible 11, easter eggs). It is never typed back in; saving is
## automatic. The same progress always gives the same mantra.
func mantra() -> String:
	var rooms: Array = data.get("visited", {}).keys()
	rooms.sort()
	var taken: Array = data.get("collected", {}).keys()
	taken.sort()
	var src := JSON.stringify([data.get("rank", 0), data.get("xp", 0), data.get("gold", 0), data.get("abilities", {}),
		data.get("equipment", {}), data.get("rings", []), taken, rooms, data.get("flags", {}), data.get("save_room", "")], "", true)
	var h := src.sha256_buffer()
	var out := ""
	for i in 16:
		if i > 0 and i % 4 == 0:
			out += " "
		out += MANTRA_LETTERS[h[i] % MANTRA_LETTERS.length()]
	return out


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
		banner.emit("Rank up: " + rank_name(), "You gain a skill point. Seek a Guru to be named and taught.")
		Sfx.play("rank", 0.0)


## The title you have earned but no Guru has named yet ("" if none).
func unnamed_title() -> String:
	return rank_name() if int(data.rank) > int(data.get("named_rank", 0)) else ""


## A Guru names you by your current rank. Returns the title.
func name_title() -> String:
	data.named_rank = int(data.rank)
	return rank_name()


## How many times the Forepaw smith has tempered blade `blade_id` (0 to 2).
func temper_level(blade_id: String) -> int:
	return int(data.get("tempers", {}).get(blade_id, 0))


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
	p.equipped_spell = String(data.get("spell", "deluge"))
	p.gold = int(data.gold)
	p.elixirs = int(data.elixirs)
	p.ointments = int(data.ointments)
	refresh_stats(p)
	p.restore()


## Recomputes the player's derived stats from base stats, gear and skills.
## Current health, magic and potions are clamped, not refilled.
func refresh_stats(p: Player) -> void:
	var eq: Dictionary = data.equipment
	var blade_id := String(eq.blade)
	if GameData.item(blade_id).is_empty():
		# A blade this build lacks (pass 138): the Short Sword, untempered.
		blade_id = "short_sword"
	var blade := GameData.item(blade_id)
	var temper := 1.0 + TEMPER_BONUS * temper_level(blade_id)
	p.slash_damage = roundi(int(blade.slash) * temper)
	p.heavy_damage = roundi(int(blade.heavy) * temper)
	p.reach_bonus = float(blade.reach)
	p.arc_bonus = float(blade.get("arc", 0.0))
	p.swing_mult = float(blade.get("swing", 1.0))
	# Armor and helmet stack by what each lets through (bible 5.2): Battle Suit
	# (60%) under the Battle Helmet (10%) lets 0.4 x 0.9 = 36% through.
	var helmet := GameData.item(String(eq.get("helmet", "")))
	p.defense = 1.0 - (1.0 - float(GameData.item(eq.armor).get("defense", 0.0))) * (1.0 - float(helmet.get("defense", 0.0)))
	p.has_shield = eq.shield != "" and not bool(blade.get("two_handed", false))
	p.guard_reduction = float(GameData.item(eq.shield).get("guard", p.combat.guard_reduction))
	p.reflects = p.has_shield and bool(GameData.item(eq.shield).get("reflect", false))
	p.melee_mult = 1.0 + (0.1 if has_skill("keen_edge") else 0.0) + (0.1 if has_skill("keener_edge") else 0.0)
	p.riposte = has_skill("riposte")
	p.bloodletting = has_skill("bloodletting")
	p.thrust = has_skill("thrust")
	p.executioner = has_skill("executioner")
	p.spell_cost_mult = 0.85 if has_skill("thrift") else 1.0
	p.chain_thunder = has_skill("chain_thunder")
	p.time_thief = has_skill("time_thief")
	p.mantra_of_death = has_skill("mantra_of_death")
	p.last_stand = has_skill("last_stand")
	p.second_wind = has_skill("second_wind")
	p.wanderers_grace = has_skill("wanderers_grace")
	p.feather_fall = has_skill("feather_fall")
	p.ground_combo_length = 4 if has_skill("fourth_strike") else 3
	p.mp_hit_mult = 1.5 if has_skill("siphon") else 1.0
	p.gold_mult = 1.1 if has_skill("gold_sense") else 1.0
	p.magnet_mult = 1.6 if has_skill("gold_sense") else 1.0
	p.rising_cut = has_skill("rising_cut")
	p.down_strike_mult = 1.5 if has_skill("mattock_mastery") else 1.0
	p.spell_pierce = has_skill("deluge_pierce")
	p.tilte_swarm = has_skill("tilte_swarm")
	p.drink_mult = 0.6 if has_skill("quick_draught") else 1.0
	p.bonus_air_dashes = 1 if has_skill("second_stride") else 0
	# The Battle Helmet is worth one mask on top (bible 5.2).
	p.max_hp = int(data.max_hp) + (RESILIENCE_HP if has_skill("resilience") else 0) + int(helmet.get("hp", 0))
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
	data.spell = p.equipped_spell
	data.gold = p.gold
	data.elixirs = p.elixirs
	data.ointments = p.ointments


## Applies a permanent stat item (Life Fruit, Mana Dew, a Potion, Mantra or Meteor Shard) and
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
		"meteor_shard":
			data.meteor_shards = int(data.meteor_shards) + 1
			return "You carry %d. The Forepaw smith folds one into a second temper." % int(data.meteor_shards)
	return ""


# --- Save files --------------------------------------------------------------------

func save_game(to_slot := -1) -> bool:
	if to_slot >= 0:
		slot = to_slot
	data.play_time = float(data.get("play_time", 0.0)) + play_time
	play_time = 0.0
	return write_safely(SAVE_PATH % slot, JSON.stringify(data, "\t"))


## Writes `text` to `path` without ever leaving it half-written (pass 109): the
## text goes to a temp file first and is read back, then the old file becomes
## the `.bak` and the temp file takes its place. A failed write leaves the last
## good file as it was.
static func write_safely(path: String, text: String) -> bool:
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("Could not write %s" % path)
		return false
	f.store_string(text)
	f.close()
	if FileAccess.get_file_as_string(tmp) != text:
		push_warning("%s did not write whole; the last good copy is kept" % path)
		DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp))
		return false
	var real := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(path + ".bak"):
			DirAccess.remove_absolute(real + ".bak")
		DirAccess.rename_absolute(real, real + ".bak")
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), real) == OK


func has_save(which: int) -> bool:
	var path := SAVE_PATH % which
	return FileAccess.file_exists(path) or FileAccess.file_exists(path + ".bak")


## Loads a slot, or its `.bak` if the file itself is damaged. On failure the
## current data is left untouched.
func load_game(from_slot: int) -> bool:
	var path := SAVE_PATH % from_slot
	var loaded := {}
	for p: String in [path, path + ".bak"]:
		if not FileAccess.file_exists(p):
			continue
		# JSON.parse_string logs an engine error for a damaged file; the warning
		# below says it plainly instead (pass 215).
		var json := JSON.new()
		loaded = sanitize(json.data if json.parse(FileAccess.get_file_as_string(p)) == OK else null)
		if not loaded.is_empty():
			if p != path:
				push_warning("Save slot %d was damaged; loaded its backup" % from_slot)
			break
		push_warning("%s is not a save" % p)
	if loaded.is_empty():
		return false
	data = loaded
	slot = from_slot
	play_time = 0.0
	return true


## Whatever a save file held, made into a whole save (pass 109): every key of
## fresh(), each of its own type, so a damaged, hand-edited or older file can
## never leave a hole or a wrong type behind. Keys a newer build added are
## kept. Returns {} when it isn't a save at all (not an object, or no sign of
## one).
static func sanitize(src: Variant) -> Dictionary:
	if not src is Dictionary or not (src as Dictionary).has("save_room"):
		return {}
	var out := fresh()
	for k: Variant in src:
		if k is String:
			out[k] = _coerce(out[k], src[k]) if out.has(k) else src[k]
	out.version = VERSION
	# Items renamed since a save was written keep their place and temper (pass 184).
	for old: String in RENAMED_ITEMS:
		var now: String = RENAMED_ITEMS[old]
		if String(out.equipment.get("blade", "")) == old:
			out.equipment.blade = now
		if out.tempers.has(old):
			out.tempers[now] = maxi(int(out.tempers.get(now, 0)), int(out.tempers[old]))
			out.tempers.erase(old)
	# Pickups moved since a save was written stay taken (pass 213).
	for old: String in MOVED_PICKUPS:
		if out.collected.has(old):
			out.collected[MOVED_PICKUPS[old]] = true
			out.collected.erase(old)
	# The Battle Helmet left the shield slot for its own (pass 185). It had
	# guarded and turned shots like the Magic Shield, and with it on every
	# shield showed as owned, so the hand it held gets the Magic Shield.
	if String(out.equipment.get("shield", "")) == "battle_helmet":
		out.equipment.helmet = "battle_helmet"
		out.equipment.shield = "magic_shield"
	# A slot holds its own kind (pass 191): a known item worn in the wrong
	# slot (a sword as a helmet) comes off, and a blade falls back to the
	# Short Sword. An unknown id stays, as pass 138 keeps it, and plays as none.
	for slot: String in GEAR_SLOTS:
		var kind := String(GameData.item(String(out.equipment.get(slot, ""))).get("kind", ""))
		if kind != "" and kind != slot:
			out.equipment[slot] = "short_sword" if slot == "blade" else ""
	# Gear kept since pass 186: whatever is worn, and the starting blade.
	var gear: Array = _unique_strings(out.gear)
	for i in gear.size():
		gear[i] = RENAMED_ITEMS.get(gear[i], gear[i])
	for slot: String in GEAR_SLOTS:
		var worn := String(out.equipment.get(slot, ""))
		if worn != "" and not gear.has(worn):
			gear.append(worn)
	if not gear.has("short_sword"):
		gear.push_front("short_sword")
	out.gear = gear
	# Containers whose entries the game reads by shape.
	out.skills = _unique_strings(out.skills)
	out.dyes = _unique_strings(out.dyes)
	out.rings = out.rings.filter(func(v: Variant) -> bool: return v is String)
	out.pins = out.pins.filter(func(v: Variant) -> bool:
		return v is Array and v.size() == 3 and v[0] is String and _is_number(v[1]) and _is_number(v[2]))
	if not _is_point(out.save_pos):
		out.save_pos = [0, 0]
	# Keys are counts (the cards) or kept-for-good flags (the Lantern and Sky Keys).
	for kind: Variant in out.keys.keys():
		var v: Variant = out.keys[kind]
		if not (kind is String and (v is bool or (_is_number(v) and float(v) >= 0.0))):
			out.keys.erase(kind)
		elif _is_number(v):
			out.keys[kind] = int(v)  # JSON keeps counts as floats; a save comes back as it went (pass 174)
	for id: Variant in out.trials.keys():
		if not _is_number(out.trials[id]) or float(out.trials[id]) < 0.0:
			out.trials.erase(id)
	for room: Variant in out.gurus.keys():
		if not _is_point(out.gurus[room]):
			out.gurus.erase(room)
	if not out.purse.is_empty() and not (out.purse.get("room") is String and _is_number(out.purse.get("x"))
			and _is_number(out.purse.get("y")) and _is_number(out.purse.get("gold"))):
		out.purse = {}
	# Nothing falls below a new game's: no zero health, no negative gold.
	var base := fresh()
	for k: String in base:
		if base[k] is int or base[k] is float:
			var low: float = base[k] if k in ["max_hp", "max_mp", "flask_max"] else 0.0
			out[k] = maxi(int(out[k]), int(low)) if base[k] is int else maxf(float(out[k]), low)
	return out


## The strings of `list`, each once (pass 138): a skill listed twice would be
## refunded twice by a respec.
static func _unique_strings(list: Array) -> Array:
	var out := []
	for v: Variant in list:
		if v is String and not out.has(v):
			out.append(v)
	return out


## `v` if it has the type of `default` (numbers convert, since JSON keeps every
## number as a float), else `default`. Dictionaries are merged key by key.
static func _coerce(default: Variant, v: Variant) -> Variant:
	if default is Dictionary:
		if not v is Dictionary:
			return default
		var d: Dictionary = default.duplicate(true)
		for k: Variant in v:
			if k is String:
				d[k] = _coerce(d[k], v[k]) if d.has(k) else v[k]
		return d
	if default is int or default is float:
		if not _is_number(v):
			return default
		return int(v) if default is int else float(v)
	if typeof(default) != typeof(v):
		return default
	return v


static func _is_number(v: Variant) -> bool:
	return (v is int or v is float) and is_finite(float(v))


static func _is_point(v: Variant) -> bool:
	return v is Array and v.size() == 2 and _is_number(v[0]) and _is_number(v[1])


func delete_save(which: int) -> void:
	var path := SAVE_PATH % which
	for p: String in [path, path + ".bak", path + ".tmp"]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
