class_name KeyDoor
extends StaticBody2D
## A locked door (three tiles tall). Walk into it holding the right key and it
## unlocks for good; without one it tells you what it needs. Kinds: "jack" (a
## wooden door with a spade, legend `J`) and "sky" (Dartmoor's upper gate, pale
## shrine stone with a gold lightning glyph, legend `g`: Borabohra's Sky Key).

const WOOD := Color("8a5a34")
const WOOD_DARK := Color("5e3b22")
const IRON := Color("6b6380")
const GLYPH := Color("ffd24a")
const SIZE := Vector2(16, 48)
const SHRINE := Color("c9c4d6")
const SHRINE_DARK := Color("8d84a3")
const SKY := Color("b8a8ff")

var kind := "jack"
var persist_id := ""

var _told := false


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = SIZE
	shape.shape = rect
	shape.position = Vector2(0, -SIZE.y * 0.5)
	add_child(shape)
	z_index = -1


func _physics_process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player") as Player
	if p == null or p.dead:
		return
	if kind == "sky":
		queue_redraw()
	var touching := absf(p.global_position.x - global_position.x) < SIZE.x * 0.5 + 8.0 and absf(p.global_position.y - global_position.y) < 8.0
	if not touching:
		_told = false
		return
	if GameState.key_count(kind) > 0:
		open()
	elif not _told:
		_told = true
		GameState.toast.emit("A %s door. You need a %s Key." % [kind.capitalize(), kind.capitalize()])
		Sfx.play("fizzle", 0.0)


func open() -> void:
	GameState.add_key(kind, -1)
	if persist_id != "":
		GameState.collect(persist_id)
	GameState.toast.emit("The %s Key turns." % kind.capitalize())
	Sfx.play("door", 0.0)
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -24)
	queue_free()


func _draw() -> void:
	if kind == "sky":
		_draw_sky_gate()
		return
	draw_rect(Rect2(-8, -48, 16, 48), WOOD_DARK)
	draw_rect(Rect2(-7, -47, 14, 47), WOOD)
	for y in [-40, -24, -8]:
		draw_rect(Rect2(-8, y, 16, 3), IRON)
	# Spade glyph (the Jack suit).
	var c := Vector2(0, -31)
	draw_circle(c + Vector2(-2, 1), 2.0, GLYPH)
	draw_circle(c + Vector2(2, 1), 2.0, GLYPH)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-4, 1), c + Vector2(0, -4), c + Vector2(4, 1)]), GLYPH)
	draw_rect(Rect2(c + Vector2(-1, 2), Vector2(2, 3)), GLYPH)


func _draw_sky_gate() -> void:
	draw_rect(Rect2(-8, -48, 16, 48), SHRINE_DARK)
	draw_rect(Rect2(-7, -47, 14, 47), SHRINE)
	for y in [-44, -6]:
		draw_rect(Rect2(-8, y, 16, 3), GLYPH)
	# A lightning glyph, pulsing faintly.
	var a := 0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.004)
	var bolt := PackedVector2Array([Vector2(1, -38), Vector2(-3, -27), Vector2(1, -27), Vector2(-2, -16)])
	draw_polyline(bolt, SKY * Color(1, 1, 1, a), 3.0)
	draw_polyline(bolt, GLYPH, 1.0)
