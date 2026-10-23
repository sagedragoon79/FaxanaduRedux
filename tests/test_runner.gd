extends Node
## Headless test runner. Run with:
##   godot --headless --path . --fixed-fps 60 res://tests/test_runner.tscn
## Exits with code 1 if any check fails.

const SUITES := [
	preload("res://tests/test_movement.gd"),
	preload("res://tests/test_abilities.gd"),
	preload("res://tests/test_world.gd"),
	preload("res://tests/test_combat.gd"),
	preload("res://tests/test_enemies.gd"),
	preload("res://tests/test_soak.gd"),
	preload("res://tests/test_rooms.gd"),
]

var _passed := 0
var _failed := 0
var _failures: Array[String] = []
var _filter := ""


func _ready() -> void:
	Feel.hitstop_enabled = false
	Feel.rumble_enabled = false
	Sfx.volume_db = -80.0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--filter="):
			_filter = arg.trim_prefix("--filter=")
	await get_tree().physics_frame
	for suite_script: GDScript in SUITES:
		var suite: TestSuite = suite_script.new()
		suite.runner = self
		for m in suite.get_method_list():
			var name: String = m["name"]
			if not name.begins_with("test_") or (_filter != "" and not name.contains(_filter)):
				continue
			var arena := Node2D.new()
			add_child(arena)
			suite.arena = arena
			suite.current_test = name
			var before := _failed
			await Callable(suite, name).call()
			print("%s %s" % ["PASS" if _failed == before else "FAIL", name])
			arena.queue_free()
			await get_tree().physics_frame
	print("\n%d checks passed, %d failed" % [_passed, _failed])
	for f in _failures:
		print("  - " + f)
	get_tree().quit(1 if _failed > 0 else 0)


func record(test: String, ok: bool, msg: String) -> void:
	if ok:
		_passed += 1
	else:
		_failed += 1
		_failures.append("%s: %s" % [test, msg])
