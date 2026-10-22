class_name DebugHud
extends CanvasLayer
## Prototype overlay: ability toggles, live movement readouts and controls.

var player: Player
var _label: Label


func _ready() -> void:
	layer = 10
	_label = Label.new()
	_label.position = Vector2(6, 4)
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_color_override("font_color", Color("f1ead2"))
	_label.add_theme_color_override("font_outline_color", Color("1d1a2b"))
	_label.add_theme_constant_override("outline_size", 3)
	add_child(_label)


func _process(_delta: float) -> void:
	if player == null:
		return
	var a := player.abilities
	var on := func(k: String) -> String: return "ON " if a[k] else "off"
	_label.text = "HP %d/%d   vel %4d,%4d   %s\n" % [player.hp, player.max_hp, player.velocity.x, player.velocity.y, PlayerVisual.current_pose(player)] \
		+ "F1 Glove %s  F2 Mattock %s  F3 Wing Boots %s  F4 Elven Stride %s\n" % [on.call("glove"), on.call("mattock"), on.call("boots"), on.call("stride")] \
		+ "Move: arrows/WASD  Jump: Space/Z  Attack: X (down in air = pogo)  Dash: C/Shift  Reset: R  HUD: F6"
