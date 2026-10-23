class_name BossLantern
extends BossSegment
## A soul-lantern hung on Ripasheiku's legs: a hitbox the boss moves, and a
## light (group "light") that clears the Mist's fog around it until it breaks.

## How far its glow clears the fog (see Fog).
var light_radius := 70.0


func _ready() -> void:
	radius = 7.0
	super._ready()
	add_to_group("light")


## Breaks it: no more hitbox, no more light.
func shatter() -> void:
	dead = true
	set_active(false)
	remove_from_group("light")
