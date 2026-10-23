class_name RootHeart
extends Area2D
## The swollen sap heart that feeds a room's root-gates (design bible 3). Strike
## it with the blade and every gate in the room withers open. Room legend `N`.

const AMBER := Color("f0c02e")
const AMBER_HOT := Color("ffe27a")
const AMBER_DARK := Color("a8641a")
const HUSK := Color("4a3020")
const HUSK_LIGHT := Color("6e4a2e")
const ROOT := Color("5e3a22")

var room: Room
var struck := false
var _t := randf() * TAU
var _flash := 0.0


func _ready() -> void:
	# On the hazard layer only so the blade's query finds it; it is not in the
	# "hazard" group, so touching it does no harm.
	collision_layer = Player.LAYER_HAZARD
	collision_mask = 0
	monitoring = false
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	shape.position = Vector2(0, -8)
	add_child(shape)


func take_hit(_damage: int, _dir: Vector2) -> void:
	if struck:
		return
	struck = true
	_flash = 0.15
	var d := Dust.new()
	d.setup("debris")
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -7)
	Sfx.play("splat", 0.0)
	Feel.hitstop(0.08)
	Feel.add_trauma(0.3)
	if room != null:
		room.open_root_gates()


func _physics_process(delta: float) -> void:
	_t += delta * 2.5
	_flash -= delta
	queue_redraw()


func _draw() -> void:
	# 2x render density: `_px` takes half-pixels. Feet at the origin.
	_px(-16, -3, 32, 3, ROOT)
	_px(-10, -6, 20, 3, ROOT)
	if struck:
		_px(-9, -16, 18, 10, HUSK)
		_px(-6, -19, 12, 3, HUSK)
		_px(-5, -16, 3, 4, HUSK_LIGHT)
		return
	var swell := roundi(sin(_t) * 1.0)
	# A round, pulsing bulb, built row by row so its edge stays pixel-crisp.
	var rx := 12.0 + swell
	var ry := 10.0 + swell * 0.5
	var cy := -14.0 - swell * 0.5
	draw_circle(Vector2(0, cy * 0.5), (rx + 6.0) * 0.5, Color(AMBER, 0.16 + 0.08 * sin(_t)))
	var body := AMBER_HOT if _flash > 0.0 else AMBER
	for hy in range(roundi(cy - ry), roundi(cy + ry)):
		var f := (hy + 0.5 - cy) / ry
		var half := roundi(rx * sqrt(maxf(0.0, 1.0 - f * f)))
		if half <= 0:
			continue
		_px(-half, hy, half * 2, 1, AMBER_DARK)
		if half > 1:
			var shade := body if f > -0.55 else AMBER_HOT
			_px(-half + 1, hy, half * 2 - 2, 1, shade)
	_px(-7, roundi(cy) - 6, 4, 3, AMBER_HOT)
	# Veins.
	_px(-1, roundi(cy) - 7, 1, 13, AMBER_DARK)
	_px(5, roundi(cy) - 4, 1, 9, AMBER_DARK)
	_px(-6, roundi(cy) - 1, 1, 7, AMBER_DARK)


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
