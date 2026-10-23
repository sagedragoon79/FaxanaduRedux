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
}
## How far the player must be from the entry door before the fight starts.
const START_DISTANCE := 64.0
const OPEN_DELAY := 1.2

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
	if reward.has("ability"):
		# The ability the boss guarded (the Foreman drops the Mattock from its back).
		var p := get_tree().get_first_node_in_group("player") as Player
		GameState.data.abilities[reward.ability] = true
		if p != null:
			p.abilities[reward.ability] = true
			GameState.capture(p)
		GameState.banner.emit(reward.title, reward.text)
	else:
		GameState.banner.emit(reward.get("ring_name", "Victory"), "+%d skill point" % points if points == 1 else "+%d skill points" % points)
	_open_timer = OPEN_DELAY
	Music.play("", 2.5)
	won.emit()


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
	seal.style = "iron" if room.zone == "tower" else "roots"
	seal.size = area.size
	seal.position = area.position
	room.add_child(seal)
	seals[n] = seal


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
