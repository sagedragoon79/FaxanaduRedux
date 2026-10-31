class_name TestSuite
extends RefCounted
## Base for test suites. Each `test_*` method runs in a fresh arena node and
## may await physics frames. Inputs set right after an await apply to that frame.

## Where Settings points while tests run (pass 231), so no test can ever load
## or overwrite the player's own user://settings.cfg. The runner sets it
## before every test.
const SETTINGS_PATH := "user://test_runner_settings.cfg"

var runner: Node
var arena: Node2D
var current_test := ""
## Set by a test that means to provoke engine errors (a damaged save, a bad
## settings file); the runner otherwise fails any test that logs one (pass 215).
var allows_engine_errors := false


func expect_engine_errors() -> void:
	allows_engine_errors = true


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


# --- Multi-room helpers (World tests) -------------------------------------------

## A walled box of `w` x `h` tiles with a 3-tile-thick floor.
func grid_rows(w: int, h: int) -> Array:
	var rows := []
	for y in h:
		var row := []
		for x in w:
			row.append("#" if y == 0 or y >= h - 3 or x == 0 or x == w - 1 else ".")
		rows.append(row)
	return rows


func put_tiles(rows: Array, x: int, y: int, ch: String, w := 1, h := 1) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			rows[yy][xx] = ch


func room_text(header: Array, rows: Array) -> String:
	var lines := PackedStringArray(header)
	lines.append("---")
	for row: Array in rows:
		lines.append("".join(PackedStringArray(row)))
	return "\n".join(lines)


## Starts a fresh game in a World built from `rooms` (id -> room text), with no fades
## and a scripted player.
func make_world(rooms: Dictionary, start_id := "test/a", at := Vector2.INF) -> World:
	GameState.new_game()
	var w := World.new()
	w.instant = true
	w.texts = rooms
	arena.add_child(w)
	w.build_catalog()
	w.start(start_id, at)
	w.player.input.scripted = true
	return w


## Feet position for a player standing in tile (x, y).
func cell_feet(x: int, y: int) -> Vector2:
	return Vector2(x * Room.TILE + 8, (y + 1) * Room.TILE)


## Center of tile (x, y).
func cell_center(x: int, y: int) -> Vector2:
	return Vector2(x * Room.TILE + 8, y * Room.TILE + 8)


## Whether `text` writes `f` as the bible does, standing alone (not inside a
## longer number such as 0.35, 135 or 1,350). A pass number ("pass 330") is
## not a setting, so it never counts. Strict (pass 346; since pass 347 the only
## reading, which every bible-number test shares): a number under 100 that is
## not whole counts only as itself (0.35, 35%, 350 ms), never rounded to a
## whole one, so 1.35 is not found in a "1" and 0.09 not in a "0". Only a
## derived number of 100 or more (gravity from 2h/t²) may be given to the px.
func written_exactly_in(text: String, f: float) -> bool:
	var passes := RegEx.create_from_string("(?i)pass(es)? \\d+((, | and | to |-)\\d+)*")
	text = passes.sub(text, "pass", true)
	var forms := [String.num(f), "%.2f" % f]
	var wholes := [roundi(f)] if is_equal_approx(f, roundf(f)) else ([floori(f), roundi(f)] if absf(f) >= 100.0 else [])
	for i: int in wholes:
		forms.append(str(i))
		if i >= 1000:
			forms.append("%d,%03d" % [i / 1000, i % 1000])
	if f > 0.0 and f < 1.0:
		forms.append("%d ms" % roundi(f * 1000.0))
		forms.append("%d%%" % roundi(f * 100.0))
	for form: String in forms:
		var re := RegEx.create_from_string("(?<![\\d.,])%s(?!\\d|,\\d)" % form.replace(".", "\\."))
		if re.search(text) != null:
			return true
	return false
