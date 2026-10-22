extends Node
## Registers the input map in code so bindings live in one readable place and
## can be remapped at runtime later. Keyboard and gamepad are both bound.

const DEADZONE := 0.35

const BINDINGS := {
	"move_left": {"keys": [KEY_LEFT, KEY_A], "buttons": [JOY_BUTTON_DPAD_LEFT], "axis": [JOY_AXIS_LEFT_X, -1.0]},
	"move_right": {"keys": [KEY_RIGHT, KEY_D], "buttons": [JOY_BUTTON_DPAD_RIGHT], "axis": [JOY_AXIS_LEFT_X, 1.0]},
	"move_up": {"keys": [KEY_UP, KEY_W], "buttons": [JOY_BUTTON_DPAD_UP], "axis": [JOY_AXIS_LEFT_Y, -1.0]},
	"move_down": {"keys": [KEY_DOWN, KEY_S], "buttons": [JOY_BUTTON_DPAD_DOWN], "axis": [JOY_AXIS_LEFT_Y, 1.0]},
	"jump": {"keys": [KEY_SPACE, KEY_Z, KEY_K], "buttons": [JOY_BUTTON_A]},
	"attack": {"keys": [KEY_X, KEY_J], "buttons": [JOY_BUTTON_X]},
	"dash": {"keys": [KEY_C, KEY_L, KEY_SHIFT], "buttons": [JOY_BUTTON_B, JOY_BUTTON_RIGHT_SHOULDER], "trigger": JOY_AXIS_TRIGGER_RIGHT},
	"debug_glove": {"keys": [KEY_F1]},
	"debug_mattock": {"keys": [KEY_F2]},
	"debug_boots": {"keys": [KEY_F3]},
	"debug_stride": {"keys": [KEY_F4]},
	"debug_reset": {"keys": [KEY_F5, KEY_R], "buttons": [JOY_BUTTON_BACK]},
	"debug_hud": {"keys": [KEY_F6]},
}


func _ready() -> void:
	for action: String in BINDINGS:
		var spec: Dictionary = BINDINGS[action]
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		InputMap.add_action(action, DEADZONE)
		for key: Key in spec.get("keys", []):
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
		for button: JoyButton in spec.get("buttons", []):
			var jb := InputEventJoypadButton.new()
			jb.button_index = button
			InputMap.action_add_event(action, jb)
		if spec.has("axis"):
			var jm := InputEventJoypadMotion.new()
			jm.axis = spec["axis"][0]
			jm.axis_value = spec["axis"][1]
			InputMap.action_add_event(action, jm)
		if spec.has("trigger"):
			var jt := InputEventJoypadMotion.new()
			jt.axis = spec["trigger"]
			jt.axis_value = 1.0
			InputMap.action_add_event(action, jt)
