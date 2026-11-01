class_name ListMenu
extends Control
## A centered panel with a title, a list of rows and a description of the
## selected row. Shops, the Guru and the skill tree all use it. The game is
## paused while it is open.
##
## Rows come from a provider callable (so they refresh after each choice):
## each row is {label, right (text on the right), detail, enabled, header}.
## Header rows are section titles and can't be selected.
##
## Optional hooks, cleared on each open(): `on_adjust(index, step)` runs on
## Left/Right (option values), `on_back` runs instead of closing on Dash (sub
## menus), and `capture(event)` takes the next key or pad button press (rebinding).

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

var on_adjust := Callable()
var on_back := Callable()
var capture := Callable()
## The frame the menu last closed on, so the key that closed it can't reopen it.
var closed_frame := -1

var _provider: Callable
var _on_select: Callable
var _footer: Callable
var _grace := 0.0
var _scroll := 0
var _flash := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	add_to_group("list_menu")
	visible = false


## Opens the menu. `provider` returns the rows; `on_select(index)` runs on
## confirm; `footer` returns a status line (gold, points).
func open(menu_title: String, menu_subtitle: String, provider: Callable, on_select: Callable, footer := Callable()) -> void:
	title = menu_title
	subtitle = menu_subtitle
	_provider = provider
	_on_select = on_select
	_footer = footer
	on_adjust = Callable()
	on_back = Callable()
	capture = Callable()
	cursor = 0
	_scroll = 0
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
	capture = Callable()
	closed_frame = Engine.get_process_frames()
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


## Left/Right on the selected row, for menus with values.
func adjust(step: int) -> void:
	if rows.is_empty() or not on_adjust.is_valid() or not rows[cursor].get("enabled", true):
		return
	on_adjust.call(cursor, step)
	Sfx.play("blip", 0.0, -6.0)
	if is_open:
		refresh()


## Dash, Block or Pause: back out of a sub menu, or close.
func back() -> void:
	if on_back.is_valid():
		on_back.call()
	else:
		close()


func _input(event: InputEvent) -> void:
	if not is_open or not capture.is_valid():
		return
	var key: bool = event is InputEventKey and event.pressed and not event.echo
	if key or (event is InputEventJoypadButton and event.pressed):
		get_viewport().set_input_as_handled()
		var take := capture
		capture = Callable()
		_grace = INPUT_GRACE
		take.call(event)
		if is_open:
			refresh()


func _process(delta: float) -> void:
	if not is_open:
		return
	_grace -= delta
	_flash = maxf(_flash - delta, 0.0)
	if _grace <= 0.0 and not capture.is_valid():
		if Input.is_action_just_pressed("move_down"):
			move(1)
		elif Input.is_action_just_pressed("move_up"):
			move(-1)
		elif Input.is_action_just_pressed("move_left"):
			adjust(-1)
		elif Input.is_action_just_pressed("move_right"):
			adjust(1)
		elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("attack"):
			confirm()
		elif Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("block") or Input.is_action_just_pressed("pause"):
			back()
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
		var lines := PixelFont.draw_wrapped(self, Vector2(x, y), subtitle, panel.size.x - 28, 9, Color("c9b98f"), 1)
		y += (PixelFont.height() + 1) * lines + 2
	y += 4
	# Long lists scroll to keep the cursor in view.
	var fit := maxi(1, int((panel.end.y - 66 - y) / ROW_H))
	if cursor < _scroll:
		_scroll = cursor
	elif cursor >= _scroll + fit:
		_scroll = cursor - fit + 1
	_scroll = clampi(_scroll, 0, maxi(rows.size() - fit, 0))
	if _scroll > 0:
		_text(Vector2(panel.end.x - 18, y - 2), "^", 9, DIM.lightened(0.3))
	if _scroll + fit < rows.size():
		_text(Vector2(panel.end.x - 18, y + fit * ROW_H + 4), "v", 9, DIM.lightened(0.3))
	for i in range(_scroll, mini(rows.size(), _scroll + fit)):
		var row: Dictionary = rows[i]
		var top := y + (i - _scroll) * ROW_H
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
			var w := PixelFont.width(right, 10)
			_text(Vector2(panel.end.x - 14 - w, top + 12), right, 10, ACCENT if enabled else DIM)
	# Description of the selected row.
	var detail: String = rows[cursor].get("detail", "") if not rows.is_empty() else ""
	var box := Rect2(panel.position.x + 8, panel.end.y - 62, panel.size.x - 16, 38)
	draw_rect(box, Color(1, 1, 1, 0.04))
	PixelFont.draw_wrapped(self, box.position + Vector2(6, 12), detail, box.size.x - 12, 9, Color("c9b98f"), 1)
	var foot: String = _footer.call() if _footer.is_valid() else ""
	_text(Vector2(x, panel.end.y - 9), foot, 9, ACCENT)
	var hint := "Press a key or button   Esc or Start: cancel" if capture.is_valid() else ("Left/Right: change   Dash: back" if on_adjust.is_valid() else "Jump: choose   Dash: leave")
	_text(Vector2(panel.end.x - 14 - PixelFont.width(hint, 8), panel.end.y - 9), hint, 8, DIM.lightened(0.2))


func _text(pos: Vector2, s: String, size: int, color: Color) -> void:
	PixelFont.draw(self, pos, s, size, color)
