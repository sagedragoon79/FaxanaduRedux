class_name TimeStop
extends RefCounted
## The Hour Glass (design bible A8): time stops for DURATION. Falling water
## freezes into footholds (Waterfall) and enemy projectiles hang where they are
## (they check `active()`); the player and the enemies themselves go on. The
## player ticks it, so it can't outlive the one who turned the glass.

const DURATION := 2.5
## From when the glass is turned until it can be turned again.
const COOLDOWN := 8.0

static var left := 0.0
static var cooldown := 0.0


static func active() -> bool:
	return left > 0.0


static func ready_to_turn() -> bool:
	return cooldown <= 0.0


## Stops time. Returns false while the glass is still running back.
static func start() -> bool:
	if not ready_to_turn():
		return false
	left = DURATION
	cooldown = COOLDOWN
	return true


static func tick(delta: float) -> void:
	left = maxf(left - delta, 0.0)
	cooldown = maxf(cooldown - delta, 0.0)


static func reset() -> void:
	left = 0.0
	cooldown = 0.0
