extends Node
## Registers the input map in code so bindings live in one readable place.
## Keyboard and gamepad are both bound; Settings can rebind an action's first key.

const DEADZONE := 0.35

const BINDINGS := {
	"move_left": {"keys": [KEY_LEFT, KEY_A], "buttons": [JOY_BUTTON_DPAD_LEFT], "axis": [JOY_AXIS_LEFT_X, -1.0]},
	"move_right": {"keys": [KEY_RIGHT, KEY_D], "buttons": [JOY_BUTTON_DPAD_RIGHT], "axis": [JOY_AXIS_LEFT_X, 1.0]},
	"move_up": {"keys": [KEY_UP, KEY_W], "buttons": [JOY_BUTTON_DPAD_UP], "axis": [JOY_AXIS_LEFT_Y, -1.0]},
	"move_down": {"keys": [KEY_DOWN, KEY_S], "buttons": [JOY_BUTTON_DPAD_DOWN], "axis": [JOY_AXIS_LEFT_Y, 1.0]},
	"jump": {"keys": [KEY_SPACE, KEY_Z, KEY_K], "buttons": [JOY_BUTTON_A]},
	"attack": {"keys": [KEY_X, KEY_J], "buttons": [JOY_BUTTON_X]},
	"dash": {"keys": [KEY_C, KEY_L, KEY_SHIFT], "buttons": [JOY_BUTTON_B, JOY_BUTTON_RIGHT_SHOULDER], "trigger": JOY_AXIS_TRIGGER_RIGHT},
	"block": {"keys": [KEY_V, KEY_I], "buttons": [JOY_BUTTON_LEFT_SHOULDER]},
	"spell": {"keys": [KEY_F, KEY_U], "buttons": [JOY_BUTTON_Y]},
	"spell_next": {"keys": [KEY_G, KEY_O], "buttons": [JOY_BUTTON_RIGHT_STICK]},
	"heal": {"keys": [KEY_Q, KEY_H], "trigger": JOY_AXIS_TRIGGER_LEFT},
	"hourglass": {"keys": [KEY_T, KEY_E], "buttons": [JOY_BUTTON_LEFT_STICK]},
	"map": {"keys": [KEY_TAB, KEY_M], "buttons": [JOY_BUTTON_BACK]},
	"pause": {"keys": [KEY_ESCAPE, KEY_P], "buttons": [JOY_BUTTON_START]},
	"debug_glove": {"keys": [KEY_F1]},
	"debug_mattock": {"keys": [KEY_F2]},
	"debug_boots": {"keys": [KEY_F3]},
	"debug_stride": {"keys": [KEY_F4]},
	"debug_reset": {"keys": [KEY_F5, KEY_R]},
	"debug_hud": {"keys": [KEY_F6]},
	"debug_deluge": {"keys": [KEY_F7]},
}


func _ready() -> void:
	restore_defaults()


## Rebuilds every action from BINDINGS.
func restore_defaults() -> void:
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


## The physical keycode of an action's first key (0 if it has none).
func primary_key(action: String) -> int:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return int((ev as InputEventKey).physical_keycode)
	return 0


## Makes `keycode` the action's first key, replacing the default first key.
## Any other action that also had that key loses it.
func rebind(action: String, keycode: int) -> void:
	for other: String in BINDINGS:
		if other == action:
			continue
		for ev in InputMap.action_get_events(other):
			if ev is InputEventKey and int((ev as InputEventKey).physical_keycode) == keycode:
				InputMap.action_erase_event(other, ev)
	var first: InputEvent = null
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			first = ev
			break
	if first != null:
		InputMap.action_erase_event(action, first)
	var key := InputEventKey.new()
	key.physical_keycode = keycode as Key
	InputMap.action_add_event(action, key)
	# Put it back first: the menus show and swap the first key.
	var events := InputMap.action_get_events(action)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)
	for ev in events:
		if ev != key:
			InputMap.action_add_event(action, ev)


## A short name for the key an action uses ("Space", "X").
func key_name(action: String) -> String:
	var code := primary_key(action)
	return OS.get_keycode_string(code as Key) if code != 0 else "-"
