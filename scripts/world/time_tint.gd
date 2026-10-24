class_name TimeTint
extends CanvasModulate
## While the Hour Glass holds time still the world drains to a cold, pale blue.

const STOPPED := Color(0.72, 0.82, 1.0)


func _process(delta: float) -> void:
	var target := STOPPED if TimeStop.active() else Color.WHITE
	color = color.lerp(target, minf(1.0, delta * 10.0))
