class_name TestSuite
extends RefCounted
## Base for test suites. Each `test_*` method runs in a fresh arena node and
## may await physics frames. Inputs set right after an await apply to that frame.

var runner: Node
var arena: Node2D
var current_test := ""


func frames(n: int) -> void:
	for i in n:
		await runner.get_tree().physics_frame


## Builds a room from ASCII rows (no header needed) inside the arena.
func make_room(rows: Array) -> Room:
	var room := Room.from_text("\n".join(PackedStringArray(rows)))
	arena.add_child(room)
	return room


## Spawns a scripted player with its feet at the bottom of tile `cell`.
func make_player(room: Room, cell: Vector2i, abilities := {}) -> Player:
	var p := Player.new()
	p.position = Vector2(cell * Room.TILE) + Vector2(Room.TILE * 0.5, Room.TILE)
	p.input.scripted = true
	room.add_child(p)
	for k: String in abilities:
		p.abilities[k] = abilities[k]
	return p


func check(cond: bool, msg: String) -> bool:
	runner.record(current_test, cond, msg)
	return cond


func check_near(actual: float, expected: float, tol: float, msg: String) -> bool:
	var ok := absf(actual - expected) <= tol
	return check(ok, "%s: got %.2f, want %.2f +/- %.2f" % [msg, actual, expected, tol])
