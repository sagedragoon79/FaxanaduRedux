class_name Drop
extends CharacterBody2D
## Food and magic that defeated enemies sometimes leave (design bible 7: drops
## are gold, MP orbs and rare items). Bread heals, as it did in Faxanadu; a
## mana orb refills magic. Both pop out, settle on the floor and wait to be
## walked over, blinking before they vanish.

const GRAVITY := 700.0
const COLLECT_RANGE := 14.0
const LIFETIME := 10.0
const BREAD_HEAL := 15
const MANA_GAIN := 12.0
## Chances, per kill, of bread and of a mana orb. Tests set them to 0 or 1.
static var bread_chance := 0.08
static var mana_chance := 0.1

const CRUST := Color("b0662a")
const CRUMB := Color("e8b45a")
const CRUST_DARK := Color("6e3a1a")
const CRUMB_LIGHT := Color("fff0c2")
const MANA := Color("5ec8ff")
const MANA_CORE := Color("e6f8ff")
const MANA_DARK := Color("2a5e9e")

var kind := "bread"

var _age := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = Player.LAYER_WORLD
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(6, 4)
	shape.shape = rect
	shape.position = Vector2(0, -2)
	add_child(shape)
	z_index = 2
	if velocity == Vector2.ZERO:
		velocity = Vector2(randf_range(-40, 40), -200)


## Rolls for an enemy's drop at `at`. Returns the drop made, or null.
static func roll(parent: Node, at: Vector2) -> Drop:
	var r := randf()
	var k := ""
	if r < bread_chance:
		k = "bread"
	elif r < bread_chance + mana_chance:
		k = "mana"
	if k == "":
		return null
	var d := Drop.new()
	d.kind = k
	parent.add_child(d)
	d.global_position = at
	return d


func _physics_process(delta: float) -> void:
	_age += delta
	if _age > LIFETIME:
		queue_free()
		return
	velocity.y = minf(velocity.y + GRAVITY * delta, 400.0)
	move_and_slide()
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
	var p := get_tree().get_first_node_in_group("player") as Player
	if p != null and not p.dead and _age > 0.3 and p.body_rect().grow(COLLECT_RANGE * 0.5).has_point(global_position + Vector2(0, -3)):
		_collect(p)
		return
	queue_redraw()


func _collect(p: Player) -> void:
	var d := Dust.new()
	if kind == "bread":
		p.hp = mini(p.max_hp, p.hp + BREAD_HEAL)
		p.health_changed.emit(p.hp, p.max_hp)
		d.setup("heal")
		GameState.toast.emit("Bread. +%d health." % BREAD_HEAL)
		Sfx.play("heal", 0.1, -6.0)
	else:
		p.mp = minf(p.max_mp, p.mp + MANA_GAIN)
		d.setup("coin")
		Sfx.play("blip", 0.1, -4.0)
	get_parent().add_child(d)
	d.global_position = global_position + Vector2(0, -4)
	queue_free()


func _draw() -> void:
	if _age > LIFETIME - 2.5 and int(_age * 10.0) % 2 == 0:
		return
	# Drawn at 2x render density (design bible 12.1): `_px` takes half-pixels.
	if kind == "bread":
		# A round loaf with two scores across the crust.
		_px(-7, -9, 14, 9, CRUST_DARK)
		_px(-8, -7, 16, 6, CRUST_DARK)
		_px(-6, -10, 12, 9, CRUST)
		_px(-7, -8, 14, 6, CRUST)
		_px(-5, -9, 4, 1, CRUMB)
		_px(-3, -7, 2, 2, CRUMB)
		_px(1, -8, 2, 2, CRUMB)
		_px(3, -6, 2, 2, CRUMB)
		_px(-4, -10, 3, 1, CRUMB_LIGHT)
		_px(-8, -1, 16, 1, CRUST_DARK)
	else:
		var y := -13 + roundi(sin(_age * 5.0) * 2.0)
		_px(-5, y, 10, 12, MANA_DARK)
		_px(-6, y + 2, 12, 8, MANA_DARK)
		_px(-4, y + 1, 8, 10, MANA)
		_px(-5, y + 3, 10, 6, MANA)
		_px(-2, y + 3, 3, 3, MANA_CORE)
		_px(-3, y + 2, 2, 1, MANA_CORE)


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(Rect2(x * 0.5, y * 0.5, w * 0.5, h * 0.5), color)
