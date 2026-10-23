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
	if kind == "bread":
		# A small round loaf with a scored top.
		draw_rect(Rect2(-4, -5, 8, 5), CRUST_DARK)
		draw_rect(Rect2(-3, -6, 6, 5), CRUST)
		draw_rect(Rect2(-2, -6, 1, 1), CRUMB)
		draw_rect(Rect2(1, -5, 1, 1), CRUMB)
		draw_rect(Rect2(-4, -1, 8, 1), CRUST_DARK)
	else:
		var bob := roundf(sin(_age * 5.0))
		var y := -6.0 + bob
		draw_rect(Rect2(-3, y - 2, 6, 6), MANA_DARK)
		draw_rect(Rect2(-2, y - 3, 4, 8), MANA_DARK)
		draw_rect(Rect2(-2, y - 2, 4, 6), MANA)
		draw_rect(Rect2(-1, y - 1, 2, 2), MANA_CORE)
