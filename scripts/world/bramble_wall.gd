class_name BrambleWall
extends StaticBody2D
## One tile of a bramble wall (room legend `w`, design bible 4.5): a knot of
## dry thorn-vine that blocks like stone. Blades only snag in it, but a Fire
## spell (group "fire_target") sets it alight; the fire creeps tile to tile
## through the whole knot and leaves ash. Burnt tiles stay burnt (by room and
## tile, like a cracked wall). Fire is a supporting spell, so brambles only ever
## hide secrets. Drawn at 2x render density: `_px` takes half-pixels.

## How long a tile burns before it falls to ash, and before it lights its neighbours.
const BURN_TIME := 0.6
const SPREAD := 0.15
const VINE := Color("5a3a24")
const VINE_LIGHT := Color("8a6038")
const VINE_DARK := Color("2e1c14")
const THORN := Color("d8c8a0")
const FLAME := Color("f08a2a")
const FLAME_HOT := Color("ffd060")
const ASH := Color("3a3030")

## When set, burning is remembered in GameState (the tile stays ash).
var persist_id := ""
var burning := false
var burnt := false
var light_radius := 26.0
var _t := 0.0
var _spread_done := false
var _shape: CollisionShape2D
var _seed := 0


func _init() -> void:
	collision_layer = Player.LAYER_WORLD
	collision_mask = 0
	_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	_shape.shape = rect
	add_child(_shape)


func _ready() -> void:
	add_to_group("bramble")
	if burnt:
		_shape.disabled = true
	else:
		add_to_group("fire_target")
	_seed = int(absf(global_position.x * 7.0 + global_position.y * 13.0))


## Sets the tile alight. The fire spreads to touching bramble on its own.
func burn() -> void:
	if burning or burnt:
		return
	burning = true
	_t = 0.0
	remove_from_group("fire_target")
	add_to_group("light")
	if persist_id != "":
		GameState.collect(persist_id)
	Sfx.play("crackle", 0.1, -4.0)


func _physics_process(delta: float) -> void:
	if not burning:
		return
	_t += delta
	queue_redraw()
	if not _spread_done and _t >= SPREAD:
		_spread_done = true
		for b in get_tree().get_nodes_in_group("bramble"):
			var w := b as BrambleWall
			if w != self and w.global_position.distance_to(global_position) < 17.0:
				w.burn()
	if _t >= BURN_TIME:
		_fall_to_ash()


func _fall_to_ash() -> void:
	burning = false
	burnt = true
	remove_from_group("light")
	_shape.set_deferred("disabled", true)
	var d := Dust.new()
	d.setup("embers")
	get_parent().add_child(d)
	d.global_position = global_position
	queue_redraw()


## Already burnt in an earlier visit: nothing but a smudge of ash.
func set_burnt() -> void:
	burnt = true
	remove_from_group("fire_target")
	if is_inside_tree():
		_shape.set_deferred("disabled", true)
	else:
		_shape.disabled = true
	queue_redraw()


func _draw() -> void:
	if burnt:
		_px(-14, 12, 28, 4, ASH, 0.8)
		return
	var char_k := clampf(_t / BURN_TIME, 0.0, 1.0) if burning else 0.0
	# A dark tangle behind, ragged at the edges, then thick vines crossing it.
	for r in 8:
		var inset := 2 if (r + (_seed >> r)) % 3 == 0 else 0
		_px(-16 + inset, -16 + r * 4, 32 - inset * 2, 4, VINE_DARK, 1.0)
	var light := VINE_LIGHT.lerp(ASH, char_k)
	var mid := VINE.lerp(ASH, char_k)
	var flip := 1 if _seed % 2 == 0 else -1
	for i in 15:
		_px(flip * (-15 + i * 2) - 2, -15 + i * 2, 4, 3, light, 1.0)
		_px(flip * (13 - i * 2) - 2, -15 + i * 2, 4, 3, mid, 1.0)
	var y := -4 + (_seed % 7)
	_px(-16, y, 32, 3, mid, 1.0)
	# Pale thorns jutting off the vines.
	var thorn := THORN.lerp(ASH, char_k)
	for k in 6:
		var tx := -13 + ((_seed >> k) % 6) + (k % 3) * 9
		var ty := -13 + (k / 3) * 14 + ((_seed >> (k + 3)) % 5)
		_px(tx, ty, 3, 1, thorn, 1.0)
		_px(tx + (2 if k % 2 == 0 else -1), ty - 1, 1, 1, thorn, 1.0)
	if burning:
		var clock := _t * 14.0
		for i in 4:
			var x := -14 + i * 7
			var h := 10 + roundi(sin(clock + i * 1.7) * 3.0) + roundi((1.0 - char_k) * 14.0)
			_px(x, 16 - h, 7, h, FLAME, 0.9)
			_px(x + 2, 16 - h + 4, 3, maxi(1, h - 6), FLAME_HOT, 0.9)


func _px(x: int, y: int, w: int, h: int, color: Color, alpha: float) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), Color(color, color.a * alpha))
