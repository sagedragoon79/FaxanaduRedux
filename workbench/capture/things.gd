extends Node2D
## Workbench capture: draws each foe, guardian and pickup alone, with the game's
## own scripts and drawing code, at the game's 2x detail on a clear background,
## and saves one PNG per thing, cropped to what was drawn. Modeled on
## tools/art/lineup.gd. Nothing here changes the game.
##
## Usage: godot --path . res://workbench/capture/things.tscn -- --out=DIR [--only=a,b] [--state=NAME] [--t=0.3]
##   Foes:    every script under scripts/enemies and scripts/bosses that extends Enemy -> DIR/foes/<id>.png
##   Pickups: every ItemPickup kind -> DIR/pickups/<kind>.png
## Use forward slashes in DIR.

## The stage, in world pixels; each thing stands alone on it, one at a time.
const STAGE := Vector2(720, 480)
const SCALE := 2
## Frames to let a thing draw before it is saved.
const SETTLE := 4

var _queue: Array = []   # [make: Callable, out_path, foe: bool]
var _view: SubViewport
var _current: Node2D
var _out := ""
var _wait := 0
var _t := 0.3
var _state := "idle"


func _ready() -> void:
	var args := {}
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else ""
	var out := String(args.get("out", "user://things"))
	var only: PackedStringArray = String(args.get("only", "")).split(",", false)
	_t = float(args.get("t", "0.3"))
	_state = String(args.get("state", "idle"))
	_view = SubViewport.new()
	_view.transparent_bg = true
	_view.size = Vector2i(STAGE) * SCALE
	_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_view)
	_view.canvas_transform = Transform2D().scaled(Vector2(SCALE, SCALE))
	for dir in ["res://scripts/enemies/", "res://scripts/bosses/"]:
		for f in DirAccess.get_files_at(dir):
			if not f.ends_with(".gd") or f == "enemy.gd":
				continue
			if not "extends Enemy" in FileAccess.get_file_as_string(dir + f):
				continue
			var id := f.get_basename()
			if only.size() > 0 and not id in only:
				continue
			var path: String = dir + f
			_queue.append([func() -> Node2D: return load(path).new(), "%s/foes/%s.png" % [out, id], true])
	for kind: String in ItemPickup.INFO:
		if only.size() > 0 and not kind in only:
			continue
		var k := kind
		_queue.append([func() -> Node2D:
			var pk := ItemPickup.new()
			pk.kind = k
			return pk, "%s/pickups/%s.png" % [out, kind], false])
	print("workbench: ", _queue.size(), " things to draw")
	_next()


func _next() -> void:
	if _current != null:
		_current.queue_free()
		_current = null
	if _queue.is_empty():
		get_tree().quit()
		return
	var job: Array = _queue.pop_front()
	_current = job[0].call()
	_out = job[1]
	if job[2]:
		# Feet on a floor line two thirds down, so tall guardians fit above it.
		_current.position = Vector2(STAGE.x * 0.5, STAGE.y * 0.7)
	else:
		_current.position = STAGE * 0.5
	_view.add_child(_current)
	_current.process_mode = Node.PROCESS_MODE_DISABLED
	if job[2]:
		_current.set("state", _state)
		_current.set("state_time", _t)
		_current.set("facing", 1)
	_current.queue_redraw()
	_wait = SETTLE


func _process(_delta: float) -> void:
	if _current == null:
		return
	_wait -= 1
	if _wait > 0:
		return
	var img := _view.get_texture().get_image()
	var used := img.get_used_rect()
	if used.size.x <= 0 or used.size.y <= 0:
		printerr("workbench: drew nothing for ", _out)
	else:
		img = img.get_region(used.grow(6).intersection(Rect2i(Vector2i.ZERO, img.get_size())))
		DirAccess.make_dir_recursive_absolute(_out.get_base_dir())
		img.save_png(_out)
	_next()
