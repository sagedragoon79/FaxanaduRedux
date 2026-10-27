class_name BossSegment
extends StaticBody2D
## One hittable piece of a segmented boss (a body ring, the head, a tail
## segment). It only carries the hitbox: the boss moves it, draws it, and
## decides what a hit does. On the enemy layer, so the player's attacks and
## contact checks find it, but it never pushes the player.

var boss: Node
var index := 0
var radius := 16.0
var is_tail := false
var is_head := false
## Read by the player's contact check (0 = harmless).
var contact_damage := 0
var dead := false
## Hit flash, counted down by the boss.
var flash := 0.0
var active := false

var _shape: CollisionShape2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	add_to_group("enemy")
	add_to_group("pogo")
	_shape = CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	_shape.shape = circle
	add_child(_shape)


## Turns the hitbox on or off (off while inside a wall or the ceiling).
func set_active(on: bool) -> void:
	active = on
	collision_layer = Player.LAYER_ENEMY if on and not dead else 0


func take_hit(damage: int, dir: Vector2) -> void:
	if boss != null and active and not dead:
		var before: int = boss.get("hp") if boss.get("hp") is int else 0
		boss.hit_segment(self, damage, dir)
		# A boss that is an Enemy shows its number in Enemy.take_hit.
		if not boss is Enemy and boss.get("hp") is int:
			DamageNumber.spawn(get_parent(), global_position + Vector2(0, -14), before - int(boss.get("hp")), "heavy" if dir.length() > 1.5 else "hit")


func stagger() -> void:
	pass


## Whether the boss is open through this piece (Enemy.punishable).
func punishable() -> bool:
	if boss == null or not active or dead:
		return false
	if boss.has_method("segment_punishable"):
		return boss.segment_punishable(self)
	return boss.has_method("punishable") and boss.punishable()
