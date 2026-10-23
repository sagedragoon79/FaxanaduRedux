class_name ListMenu
extends Control
## A centered panel with a title, a list of rows and a description of the
## selected row. Shops, the Guru and the skill tree all use it. The game is
## paused while it is open.
##
## Rows come from a provider callable (so they refresh after each choice):
## each row is {label, right (text on the right), detail, enabled, header}.
## Header rows are section titles and can't be selected.

signal closed

const PANEL := Rect2(150, 46, 340, 268)
const BG := Color(0.07, 0.06, 0.11, 0.95)
const BORDER := Color("c9b98f")
const TEXT := Color("f1ead2")
const DIM := Color("6b6380")
const ACCENT := Color("ffd24a")
const CURSOR := Color(1, 0.86, 0.4, 0.14)
const ROW_H := 16.0
const INPUT_GRACE := 0.12

var title := ""
var subtitle := ""
var rows: Array = []
var cursor := 0
var is_open := false
## Where the panel sits; menus may move it (the title menu sits under the logo).
var panel := PANEL

var _provider: Callable
var _on_select: Callable
var _footer: Callable
var _grace := 0.0
var _flash := 0.0
var _font: Font


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_to_group("list_menu")
	_font = ThemeDB.fallback_font
	visible = false


## Opens the menu. `provider` returns the rows; `on_select(index)` runs on
## confirm; `footer` returns a status line (gold, points).
func open(menu_title: String, menu_subtitle: String, provider: Callable, on_select: Callable, footer := Callable()) -> void:
	title = menu_title
	subtitle = menu_subtitle
	_provider = provider
	_on_select = on_select
	_footer = footer
	cursor = 0
	refresh()
	_skip_headers(1)
	is_open = true
	visible = true
	_grace = INPUT_GRACE
	get_tree().paused = true


func refresh() -> void:
	rows = _provider.call()
	cursor = clampi(cursor, 0, maxi(rows.size() - 1, 0))


func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	get_tree().paused = false
	closed.emit()


## Runs the selected row's action. Disabled rows buzz and flash.
func confirm() -> void:
	if rows.is_empty():
		return
	var row: Dictionary = rows[cursor]
	if not row.get("enabled", true):
		_flash = 0.25
		Sfx.play("fizzle", 0.0)
		return
	_on_select.call(cursor)
	if is_open:
		refresh()


func move(step: int) -> void:
	if rows.is_empty():
		return
	cursor = wrapi(cursor + step, 0, rows.size())
	_skip_headers(step)
	Sfx.play("blip", 0.0, -8.0)


func _skip_headers(step: int) -> void:
	for i in rows.size():
		if not rows[cursor].get("header", false):
			return
		cursor = wrapi(cursor + step, 0, rows.size())


func _process(delta: float) -> void:
	if not is_open:
		return
	_grace -= delta
	_flash = maxf(_flash - delta, 0.0)
	if _grace <= 0.0:
		if Input.is_action_just_pressed("move_down"):
			move(1)
		elif Input.is_action_just_pressed("move_up"):
			move(-1)
		elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
			confirm()
		elif Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("block") or Input.is_action_just_pressed("pause"):
			close()
	queue_redraw()


func _draw() -> void:
	if not is_open:
		return
	draw_rect(panel.grow(2), BORDER)
	draw_rect(panel, BG)
	var x := panel.position.x + 14
	var y := panel.position.y + 22
	_text(Vector2(x, y), title, 14, ACCENT)
	y += 14
	if subtitle != "":
		draw_multiline_string(_font, Vector2(x, y), subtitle, HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 28, 9, 4, Color("c9b98f"))
		y += 12 * ceilf(_font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x / (panel.size.x - 28)) + 4
	y += 4
	for i in rows.size():
		var row: Dictionary = rows[i]
		var top := y + i * ROW_H
		if row.get("header", false):
			_text(Vector2(x, top + 11), String(row.label).to_upper(), 8, DIM.lightened(0.3))
			continue
		var enabled: bool = row.get("enabled", true)
		if i == cursor:
			var c := CURSOR if _flash <= 0.0 else Color(0.9, 0.25, 0.3, 0.3)
			draw_rect(Rect2(panel.position.x + 6, top, panel.size.x - 12, ROW_H - 1), c)
			draw_colored_polygon(PackedVector2Array([Vector2(x - 6, top + 4), Vector2(x - 2, top + 7.5), Vector2(x - 6, top + 11)]), ACCENT)
		_text(Vector2(x + 2, top + 12), row.label, 10, TEXT if enabled else DIM)
		var right: String = row.get("right", "")
		if right != "":
			var w := _font.get_string_size(right, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
			_text(Vector2(panel.end.x - 14 - w, top + 12), right, 10, ACCENT if enabled else DIM)
	# Description of the selected row.
	var detail: String = rows[cursor].get("detail", "") if not rows.is_empty() else ""
	var box := Rect2(panel.position.x + 8, panel.end.y - 62, panel.size.x - 16, 38)
	draw_rect(box, Color(1, 1, 1, 0.04))
	draw_multiline_string(_font, box.position + Vector2(6, 13), detail, HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 12, 9, 3, Color("c9b98f"))
	var foot: String = _footer.call() if _footer.is_valid() else ""
	_text(Vector2(x, panel.end.y - 9), foot, 9, ACCENT)
	var hint := "Jump: choose   Dash: leave"
	_text(Vector2(panel.end.x - 14 - _font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x, panel.end.y - 9), hint, 8, DIM.lightened(0.2))


func _text(pos: Vector2, s: String, size: int, color: Color) -> void:
	draw_string(_font, pos, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
