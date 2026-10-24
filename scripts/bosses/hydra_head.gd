class_name HydraHead
extends BossSegment
## One of Zorugeriru's heads: a hitbox the boss moves and a light in the fog.
## Only a solid head has a hitbox; a mist head is fog the blade passes through.
## The boss runs its moves (`mode`); the head only keeps the numbers.

## How far its glow clears the fog (see Fog): a solid head shows plainly.
var light_radius := 40.0
var solid := false
## The fourth head stays coiled out of sight until the tanks are full.
var coiled := false
## What the head is doing: idle, rear, bite, down, rise, breath_tell, breath, emerge, sink.
var mode := "idle"
var mode_time := 0.0
## Where it rests: its lane's x, and its height.
var rest := Vector2.ZERO
## Where a move started and where it goes.
var from := Vector2.ZERO
var to := Vector2.ZERO
var bit := false


func _ready() -> void:
	radius = 13.0
	super._ready()
	if not coiled:
		add_to_group("light")


func set_mode(m: String) -> void:
	mode = m
	mode_time = 0.0
	from = global_position
	bit = false


func set_solid(on: bool) -> void:
	solid = on
	set_active(on and not coiled)
	contact_damage = 10 if active else 0
	if coiled:
		remove_from_group("light")
	elif not dead:
		add_to_group("light")


## A parried bite stuns the head where it lies.
func stagger() -> void:
	if boss != null and boss.has_method("stagger_head"):
		boss.stagger_head(self)
