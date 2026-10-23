class_name DialogBox
extends Control
## Bottom-of-screen dialog box with a typewriter effect. Opens when anything
## calls `GameState.say()`. Jump, attack or Up finishes the line, then turns the
## page. The player is frozen while it is open.

const CHARS_PER_SECOND := 60.0
const INPUT_GRACE := 0.15
const BOX := Rect2(90, 262, 460, 84)
const BG := Color(0.07, 0.06, 0.11, 0.92)
const BORDER := Color("c9b98f")
const TEXT := Color("f1ead2")
const NAME := Color("ffd24a")

signal closed

var pages: Array = []
var speaker := ""
var page := 0
var shown := 0.0
var is_open := false

var _grace := 0.0
var _font: Font


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font
	visible = false
	GameState.dialog_requested.connect(open)


func open(who: String, lines: Array) -> void:
	if lines.is_empty():
		return
	speaker = who
	pages = lines
	page = 0
	shown = 0.0
	is_open = true
	visible = true
	_grace = INPUT_GRACE
	_set_frozen(true)


## Finishes the current line, or moves to the next page, or closes.
func advance() -> void:
	if not is_open:
		return
	var line: String = pages[page]
	if shown < line.length():
		shown = line.length()
		return
	page += 1
	shown = 0.0
	Sfx.play("blip", 0.0, -6.0)
	if page >= pages.size():
		close()


func close() -> void:
	is_open = false
	visible = false
	_set_frozen(false)
	closed.emit()


func _set_frozen(on: bool) -> void:
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null:
		p.frozen = on


func _process(delta: float) -> void:
	if not is_open:
		return
	_grace -= delta
	var line: String = pages[page]
	if shown < line.length():
		var before := int(shown)
		shown = minf(shown + CHARS_PER_SECOND * delta, line.length())
		if int(shown) / 3 != before / 3:
			Sfx.play("blip", 0.1, -14.0)
	if _grace <= 0.0 and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("move_up")):
		advance()
	queue_redraw()


func _draw() -> void:
	if not is_open:
		return
	draw_rect(BOX.grow(2), BORDER)
	draw_rect(BOX, BG)
	var text_pos := BOX.position + Vector2(12, 18)
	if speaker != "":
		var tab := Rect2(BOX.position + Vector2(8, -12), Vector2(_font.get_string_size(speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 12, 14))
		draw_rect(tab.grow(1), BORDER)
		draw_rect(tab, BG)
		draw_string(_font, tab.position + Vector2(6, 11), speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, NAME)
		text_pos.y += 4
	var line: String = pages[page]
	draw_multiline_string(_font, text_pos, line.substr(0, int(shown)), HORIZONTAL_ALIGNMENT_LEFT, BOX.size.x - 24, 11, 5, TEXT)
	if shown >= line.length():
		var y := BOX.end.y - 10 + roundf(sin(Time.get_ticks_msec() / 150.0))
		draw_colored_polygon(PackedVector2Array([Vector2(BOX.end.x - 16, y - 3), Vector2(BOX.end.x - 8, y - 3), Vector2(BOX.end.x - 12, y + 1)]), BORDER)
