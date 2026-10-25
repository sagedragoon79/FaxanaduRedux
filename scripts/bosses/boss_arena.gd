class_name BossArena
extends Node2D
## Runs a boss room (room header `boss: <id>`). Roots seal every door except
## the one the player came in by; once the player is well inside, that one
## seals too and the boss wakes. Beating the boss gives its reward, sets the
## `boss:<id>` flag (so it never returns) and opens the doors.

signal started
signal won

## Boss id -> how to make it and what it gives.
const BOSSES := {
	"rokusutahn": {"ring": "elf", "ring_name": "Elf Ring", "skill_points": 1},
	"foreman": {"ability": "mattock", "title": "Mattock",
		"text": "Strike down in midair to bounce off foes and spikes. Breaks cracked stone.", "music": "miniboss"},
	"zoradohna": {"ring": "ruby", "ring_name": "Ruby Ring", "skill_points": 1, "music": "zoradohna"},
	"ripasheiku": {"key": "lantern", "title": "Lantern Key", "skill_points": 1, "mana_dew": true,
		"text": "Its light opens the way to the Spring of Mist. Your magic grows.", "music": "ripasheiku"},
	"zorugeriru": {"ring": "dworf", "ring_name": "Dworf Ring", "skill_points": 1, "music": "zorugeriru"},
	"pakukame": {"title": "The Bloom Wilts", "skill_points": 1, "music": "pakukame"},
	"borabohra": {"key": "sky", "title": "Sky Key", "skill_points": 1,
		"text": "The storm breaks over the Spires. Its key opens Dartmoor's upper gate.", "music": "borabohra"},
	"king_grieve": {"ring": "demon", "ring_name": "Demon Ring", "skill_points": 1, "music": "grieve"},
	"shadow_eura": {"title": "The Mirror Breaks", "skill_points": 1, "music": "eura",
		"text": "Your shadow is gone from the glass. Nothing now stands before the gate of Zenis but its four sockets."},
	"evil_avatar": {"title": "The Avatar Shatters", "skill_points": 1, "music": "evil_one",
		"text": "Its borrowed body breaks apart, and the light that wore it flees up the veins of the meteor."},
	"evil_veins": {"title": "The Veins Go Dark", "skill_points": 1, "music": "evil_one",
		"text": "Starved of its light, the core gutters. Above, the heart of the meteor lies open."},
	"evil_one": {"title": "The Heart of the Meteor Dies", "skill_points": 1, "music": "evil_one",
		"text": "The Tree's roots close over the dead heart, and the light of its springs runs home down the trunk."},
	"drowned_warden": {"armor": "battle_suit", "title": "Battle Suit", "skill_points": 1, "music": "warden",
		"text": "The Warden's own harness, bronze and spring-stone: take 60% less damage. The Source is free."},
}
## How far the player must be from the entry door before the fight starts.
const START_DISTANCE := 64.0
const OPEN_DELAY := 1.2
## Seconds from the Evil One's death to the ending (the banner shows first).
const ENDING_DELAY := 4.0

var boss_id := ""
var room: Room
var boss: Node2D
var fighting := false
var entry_door := 0
var seals := {}  # door number -> ArenaSeal

var _open_timer := -1.0


func _ready() -> void:
	add_to_group("boss_arena")


func defeated_before() -> bool:
	return GameState.flag("boss:" + boss_id)


func _physics_process(delta: float) -> void:
	if room == null or defeated_before() and not fighting:
		return
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.get_parent() != room:
		return
	if _open_timer >= 0.0:
		_open_timer -= delta
		if _open_timer < 0.0:
			_open_doors()
		return
	if entry_door == 0:
		entry_door = _nearest_door(p.global_position)
		for n: int in room.doors:
			if n != entry_door:
				_seal(n)
		return
	if not fighting and _distance_to_door(entry_door, p.global_position) >= START_DISTANCE and p.is_on_floor():
		_start()


func _start() -> void:
	fighting = true
	_seal(entry_door)
	match boss_id:
		"rokusutahn":
			var r := Rokusutahn.new()
			r.room = room
			boss = r
			r.defeated.connect(_on_defeated)
		"foreman":
			# The golem waits at the end of the hall away from the way in.
			var f := Foreman.new()
			var w := float(room.size_tiles.x * Room.TILE)
			f.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			var px := p_x()
			f.position = Vector2(w - 6 * Room.TILE if px < w * 0.5 else 6 * Room.TILE, f.arena.end.y)
			boss = f
			f.defeated.connect(_on_defeated)
		"zoradohna":
			# The drill waits across the lift from the way in, the shaft behind it.
			var z := Zoradohna.new()
			var w := float(room.size_tiles.x * Room.TILE)
			z.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			var px := p_x()
			z.position = Vector2(w - 7 * Room.TILE if px < w * 0.5 else 7 * Room.TILE, z.arena.end.y)
			var shaft := LiftShaft.new()
			shaft.area = z.arena
			shaft.boss = z
			room.add_child(shaft)
			boss = z
			z.defeated.connect(_on_defeated)
		"ripasheiku":
			# The widow waits in the dark across the chapel from the way in.
			var r := Ripasheiku.new()
			var w := float(room.size_tiles.x * Room.TILE)
			r.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			var px := p_x()
			r.position = Vector2(w - 8 * Room.TILE if px < w * 0.5 else 8 * Room.TILE, r.floor_y())
			boss = r
			r.defeated.connect(_on_defeated)
		"zorugeriru":
			# The hydra lies coiled around the spring on its shelf in the middle.
			var z := Zorugeriru.new()
			var w := float(room.size_tiles.x * Room.TILE)
			z.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			z.position = Vector2(w * 0.5, 9 * Room.TILE - 10)
			boss = z
			z.defeated.connect(_on_defeated)
		"pakukame":
			# The bloom is rooted in the middle of the crown-leaf.
			var k := Pakukame.new()
			var w := float(room.size_tiles.x * Room.TILE)
			k.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			k.position = Vector2(w * 0.5, k.arena.end.y)
			boss = k
			k.defeated.connect(_on_defeated)
		"borabohra":
			# The roc comes down out of the storm over the middle island.
			var b := Borabohra.new()
			var w := float(room.size_tiles.x * Room.TILE)
			# The roost has open sky above the fight for the wide camera; the roc
			# keeps to the 16 rows above the floor.
			var top := float((room.size_tiles.y - 19) * Room.TILE)
			b.arena = Rect2(Room.TILE, top, w - 2 * Room.TILE, 16 * Room.TILE)
			boss = b
			b.defeated.connect(_on_defeated)
		"king_grieve":
			# The king waits before his throne, the dais at the hall's east end.
			var k := KingGrieve.new()
			var w := float(room.size_tiles.x * Room.TILE)
			k.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			k.dais = Rect2(46 * Room.TILE, 14 * Room.TILE, w - 47 * Room.TILE, 6 * Room.TILE)
			k.position = Vector2(40 * Room.TILE, k.arena.end.y)
			boss = k
			k.defeated.connect(_on_defeated)
		"shadow_eura":
			# Your reflection, on the far side of the mirror down the middle of the hall.
			var e := ShadowEura.new()
			var w := float(room.size_tiles.x * Room.TILE)
			e.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			boss = e
			e.defeated.connect(_on_defeated)
		"evil_avatar":
			# The Evil One's avatar comes down off its throne at the hall's east end.
			var a := EvilAvatar.new()
			var w := float(room.size_tiles.x * Room.TILE)
			a.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 16 * Room.TILE)
			a.position = Vector2(46 * Room.TILE, a.arena.end.y)
			boss = a
			a.defeated.connect(_on_defeated)
		"evil_veins":
			# The core hangs in the vault at the top of the shaft; its veins are in the room.
			var c := EvilCore.new()
			var w := float(room.size_tiles.x * Room.TILE)
			var h := float(room.size_tiles.y * Room.TILE)
			c.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, h - 6 * Room.TILE)
			c.position = Vector2(w * 0.5, 6 * Room.TILE)
			boss = c
			c.defeated.connect(_on_defeated)
		"evil_one":
			# The heart hangs high over the middle of its chamber, out of any blade's reach.
			var e := EvilHeart.new()
			var w := float(room.size_tiles.x * Room.TILE)
			e.arena = Rect2(Room.TILE, 4 * Room.TILE, w - 2 * Room.TILE, 17 * Room.TILE)
			e.position = Vector2(w * 0.5, 8 * Room.TILE)
			boss = e
			e.defeated.connect(_on_defeated)
		"drowned_warden":
			# The Warden rises out of the middle of the Wellspring.
			var d := DrownedWarden.new()
			d.surface_y = _surface_y()
			d.lane = Vector2(14 * Room.TILE, (room.size_tiles.x - 14) * Room.TILE)
			d.position = Vector2(room.size_tiles.x * Room.TILE * 0.5, d.surface_y + DrownedWarden.LURK_DEPTH)
			boss = d
			d.defeated.connect(_on_defeated)
		_:
			push_warning("Unknown boss: " + boss_id)
			return
	room.add_child(boss)
	boss.begin()
	Music.play(BOSSES.get(boss_id, {}).get("music", "boss"), 0.5)
	started.emit()


func _on_defeated() -> void:
	var reward: Dictionary = BOSSES.get(boss_id, {})
	GameState.set_flag("boss:" + boss_id)
	var rings: Array = GameState.data.rings
	if reward.has("ring") and not rings.has(reward.ring):
		rings.append(reward.ring)
	var points := int(reward.get("skill_points", 0))
	GameState.data.skill_points = int(GameState.data.skill_points) + points
	Sfx.play("item", 0.0)
	if reward.has("key"):
		# A key and, for the Lantern Widow, the Mana Dew she guarded.
		var p := get_tree().get_first_node_in_group("player") as Player
		GameState.add_key(reward.key)
		if reward.get("mana_dew", false) and p != null:
			GameState.grant_stat_item("mana_dew", p)
		GameState.banner.emit(reward.title, reward.text)
	elif reward.has("armor"):
		# Armor the boss wore or kept goes straight on (the Warden's Battle Suit).
		var p := get_tree().get_first_node_in_group("player") as Player
		GameState.data.equipment.armor = reward.armor
		if p != null:
			GameState.refresh_stats(p)
			GameState.capture(p)
		GameState.banner.emit(reward.title, reward.text)
	elif reward.has("ability"):
		# The ability the boss guarded (the Foreman drops the Mattock from its back).
		var p := get_tree().get_first_node_in_group("player") as Player
		GameState.data.abilities[reward.ability] = true
		if p != null:
			p.abilities[reward.ability] = true
			GameState.capture(p)
		GameState.banner.emit(reward.title, reward.text)
	else:
		GameState.banner.emit(reward.get("ring_name", reward.get("title", "Victory")), "+%d skill point" % points if points == 1 else "+%d skill points" % points)
	_open_timer = OPEN_DELAY
	Music.play("", 2.5)
	won.emit()
	if boss_id == "evil_one":
		# The last fight: the ending follows once the banner has had its moment.
		get_tree().create_timer(ENDING_DELAY, true, false, true).timeout.connect(GameState.begin_ending)


func _open_doors() -> void:
	fighting = false
	for n: int in seals:
		if is_instance_valid(seals[n]):
			seals[n].open()
	seals.clear()
	Music.for_room(room)


func _seal(n: int) -> void:
	if seals.has(n) or not room.doors.has(n):
		return
	var d: Dictionary = room.doors[n]
	var r: Rect2 = d.rect
	# The roots fill the doorway and the column inside it.
	var area: Rect2
	match d.edge:
		"left":
			area = Rect2(r.position.x, r.position.y, r.size.x + Room.TILE, r.size.y)
		"right":
			area = Rect2(r.position.x - Room.TILE, r.position.y, r.size.x + Room.TILE, r.size.y)
		_:
			return
	var seal := ArenaSeal.new()
	seal.style = "iron" if room.zone in ["tower", "daybreak", "dartmoor", "zenis", "sunken"] else "roots"
	seal.size = area.size
	seal.position = area.position
	room.add_child(seal)
	seals[n] = seal


## The top of the room's deep water (the Wellspring), from its SwimWater.
func _surface_y() -> float:
	for c in room.get_children():
		if c is SwimWater:
			var top := INF
			for cell: Vector2i in c.cells:
				top = minf(top, cell.y * Room.TILE)
			return top
	return float(room.size_tiles.y * Room.TILE) * 0.5


func p_x() -> float:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	return p.global_position.x if p != null else 0.0


func _nearest_door(pos: Vector2) -> int:
	var best := 0
	var best_d := INF
	for n: int in room.doors:
		var d := _distance_to_door(n, pos)
		if d < best_d:
			best_d = d
			best = n
	return best


func _distance_to_door(n: int, pos: Vector2) -> float:
	var r: Rect2 = room.doors[n].rect
	return Vector2(clampf(pos.x, r.position.x, r.end.x), clampf(pos.y, r.position.y, r.end.y)).distance_to(pos)
