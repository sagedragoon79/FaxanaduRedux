extends Node2D
## Art review: draws each foe in each of its states, one row per foe, at the
## game's 2x detail, and saves the sheet (design bible 15, the art loop).
## Usage: xvfb-run -a godot --path . res://tools/art/lineup.tscn -- --out=OUT.png [--only=a,b] [--t=0.3] [--max=7]

const CELL := Vector2(150, 110)
const LABEL_W := 90.0

var _rows: Array = []


func _ready() -> void:
	var args := {}
	for arg in OS.get_cmdline_user_args():
		var kv := arg.trim_prefix("--").split("=", true, 1)
		args[kv[0]] = kv[1] if kv.size() > 1 else ""
	var only: PackedStringArray = String(args.get("only", "")).split(",", false)
	var t := float(args.get("t", "0.3"))
	var files: Array[String] = []
	for dir in ["res://scripts/enemies/", "res://scripts/bosses/"]:
		for f in DirAccess.get_files_at(dir):
			if f.ends_with(".gd"):
				files.append(dir + f)
	var y := 4.0
	for path in files:
		var src := FileAccess.get_file_as_string(path)
		if not ("extends Enemy" in src) or path.ends_with("/enemy.gd"):
			continue
		var id := path.get_file().get_basename()
		if only.size() > 0 and not id in only:
			continue
		var states: Array[String] = ["idle"]
		var re := RegEx.create_from_string('set_state\\("([a-z_0-9]+)"')
		# And every state named on a case line of a `match state:` (tells opened by a helper).
		var cases := RegEx.create_from_string('(?m)^\\t+((?:"[a-z_0-9]+"(?:, )?)+):')
		var word := RegEx.create_from_string('"([a-z_0-9]+)"')
		var found: Array[String] = []
		for m in re.search_all(src):
			found.append(m.get_string(1))
		for c in cases.search_all(src):
			for w in word.search_all(c.get_string(1)):
				found.append(w.get_string(1))
		for s in found:
			if not s in states:
				states.append(s)
		states = states.slice(0, int(args.get("max", "7")))
		var x := LABEL_W
		for s in states:
			var e: Node2D = load(path).new()
			e.position = Vector2(x + CELL.x * 0.5, y + CELL.y - 16)
			add_child(e)
			e.process_mode = Node.PROCESS_MODE_DISABLED
			e.set("state", s)
			e.set("state_time", t)
			e.set("facing", 1)
			e.queue_redraw()
			x += CELL.x
		_rows.append([id, y, states])
		y += CELL.y
	var size := Vector2i(int(LABEL_W + CELL.x * int(args.get("max", "7"))), int(y + 4))
	# Everything moves into a viewport of exactly the sheet's size, at 2x.
	var view := SubViewport.new()
	view.size = size * 2
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	view.canvas_transform = Transform2D().scaled(Vector2(2, 2))
	var stage := Node2D.new()
	view.add_child(stage)
	for c in get_children():
		c.reparent(stage, false)
	var back := ColorRect.new()
	back.color = Color(0.36, 0.38, 0.42)
	back.size = Vector2(size)
	back.show_behind_parent = true
	stage.add_child(back)
	stage.move_child(back, 0)
	var labels := Labels.new()
	labels.rows = _rows
	stage.add_child(labels)
	add_child(view)
	for c in stage.get_children():
		if c is Enemy:
			c.process_mode = Node.PROCESS_MODE_DISABLED
			c.queue_redraw()
	for i in 8:
		await get_tree().process_frame
	var img := view.get_texture().get_image()
	img.save_png(String(args.get("out", "user://lineup.png")))
	get_tree().quit()


class Labels extends Node2D:
	var rows: Array = []

	func _draw() -> void:
		for r in rows:
			var y: float = r[1]
			draw_line(Vector2(0, y + CELL.y - 16), Vector2(4000, y + CELL.y - 16), Color(0.25, 0.26, 0.3), 1.0)
			PixelFont.draw(self, Vector2(2, y + 8), r[0], 1, Color.WHITE)
			var x := LABEL_W
			for s in r[2]:
				PixelFont.draw(self, Vector2(x + 2, y + 8), s, 1, Color(0.8, 0.85, 1.0))
				x += CELL.x
