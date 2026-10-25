class_name HeartSeal
extends StaticBody2D
## A wall of the meteor's living flesh across the way into its heart (Zenis,
## design bible 8.9; legend `+`, a rectangle of cells). Every blade glances
## off it except the Dragon Slayer: one cut with it and the flesh tears open
## for good. A slit of cyan light runs down its middle and an eye opens in it,
## watching you.

const FLESH := Color("5a1838")
const FLESH_LIGHT := Color("8a2a50")
const SCAR := Color("2a0a1c")
const SEAM := Color("4ae0d8")
const SEAM_CORE := Color("d8fff8")
const OUTLINE := Color("13101f")
const BEAT := 1.25

## The seal's cells (tiles).
var cells := Rect2i()
## Remembered in GameState once torn.
var persist_id := ""
## Seconds it shudders after a blade glances off it.
var _shudder := 0.0
var _torn := false
var _tear := 0.0
var _t := 0.0
var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	z_index = 1
	position = Vector2(cells.position * Room.TILE)
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(cells.size * Room.TILE)
	_shape.shape = rect
	_shape.position = rect.size * 0.5
	add_child(_shape)
	if persist_id != "" and GameState.is_collected(persist_id):
		_open(true)


func is_open() -> bool:
	return _torn


## The player's blade lands on it. Only the Dragon Slayer cuts.
func take_hit(_damage: int, dir: Vector2) -> void:
	if _torn:
		return
	if String(GameState.data.equipment.get("blade", "")) != "dragon_slayer":
		_shudder = 0.3
		var d := Dust.new()
		d.setup("guard")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(cells.size * Room.TILE) * 0.5 - Vector2(dir.x * 8.0, 0)
		Sfx.play("guard")
		var p := get_tree().get_first_node_in_group("player") as Player
		if p:
			p.velocity.x = -signf(dir.x) * 200.0
		return
	_open(false)


func _open(quiet: bool) -> void:
	_torn = true
	_tear = 1.0 if quiet else 0.0
	_shape.set_deferred("disabled", true)
	if persist_id != "":
		GameState.collect(persist_id)
	if quiet:
		return
	Sfx.play("roar")
	Sfx.play("splat")
	Feel.hitstop(0.15)
	Feel.add_trauma(0.5)
	for i in 3:
		var d := Dust.new()
		d.setup("debris")
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(cells.size.x * Room.TILE * 0.5, (i + 0.5) * cells.size.y * Room.TILE / 3.0)


func _physics_process(delta: float) -> void:
	_t += delta
	_shudder = maxf(0.0, _shudder - delta)
	if _torn:
		_tear = minf(1.0, _tear + delta * 2.5)
	queue_redraw()


func _draw() -> void:
	var w := float(cells.size.x * Room.TILE)
	var h := float(cells.size.y * Room.TILE)
	var beat := maxf(0.0, 1.0 - fmod(_t * BEAT, 1.0) * 4.0)
	var shake := sin(_t * 60.0) * 1.5 * _shudder / 0.3
	if _torn:
		# Ragged flaps pulled back to either side of the opening.
		var flap := w * 0.5 * (1.0 - _tear * 0.75)
		for side in [-1.0, 1.0]:
			var x0: float = 0.0 if side < 0.0 else w - flap
			draw_rect(Rect2(x0, 0, flap, h), FLESH)
			for i in int(h / 8.0):
				var ex: float = (x0 + flap) if side < 0.0 else x0
				draw_rect(Rect2(ex - 2.0, i * 8.0 + 2.0, 2.0 + float(i % 3), 3.0), SCAR)
		return
	draw_rect(Rect2(shake - 1.0, -1.0, w + 2.0, h + 2.0), OUTLINE)
	draw_rect(Rect2(shake, 0, w, h), FLESH.lerp(FLESH_LIGHT, beat * 0.5))
	# Folds of flesh in bands, swelling with the heartbeat.
	for i in int(h / 10.0):
		var y := i * 10.0 + 4.0
		draw_rect(Rect2(shake + 2.0, y, w - 4.0, 2.0 + beat), FLESH_LIGHT)
		draw_rect(Rect2(shake + 2.0, y + 3.0 + beat, w - 4.0, 1.0), SCAR)
	# The seam of light down its middle, and the eye in it.
	var cx := shake + w * 0.5
	draw_rect(Rect2(cx - 1.5, 4.0, 3.0, h - 8.0), Color(SEAM, 0.6 + 0.4 * beat))
	draw_rect(Rect2(cx - 0.5, 6.0, 1.0, h - 12.0), SEAM_CORE)
	var eye := Vector2(cx, h * 0.4)
	var open := 0.4 + 0.6 * absf(sin(_t * 0.7))
	draw_rect(Rect2(eye - Vector2(6, 4.0 * open + 1.0), Vector2(12, 8.0 * open + 2.0)), OUTLINE)
	draw_rect(Rect2(eye - Vector2(5, 4.0 * open), Vector2(10, 8.0 * open)), SEAM_CORE)
	var p := get_tree().get_first_node_in_group("player") as Node2D if is_inside_tree() else null
	var look := 0.0
	if p:
		look = clampf((p.global_position.x - global_position.x - w * 0.5) / 80.0, -1.0, 1.0) * 2.5
	draw_rect(Rect2(eye + Vector2(look - 1.5, -3.0 * open), Vector2(3, 6.0 * open)), OUTLINE)
