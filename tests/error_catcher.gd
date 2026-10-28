class_name ErrorCatcher
extends Logger
## Catches the engine's error messages while a test holds it, so a test can
## check that a moment logs nothing (a script error or an engine ERROR line in a
## player's log is a stability bug even when the game carries on).
##   var errors := ErrorCatcher.start()
##   ...
##   check(errors.stop().is_empty(), "...")

var caught: Array[String] = []
## Whether warnings count too (the runner's guard counts only errors).
var warnings := true
var _mutex := Mutex.new()


static func start(with_warnings := true) -> ErrorCatcher:
	var c := ErrorCatcher.new()
	c.warnings = with_warnings
	OS.add_logger(c)
	return c


## Stops catching and returns what was caught.
func stop() -> Array[String]:
	OS.remove_logger(self)
	_mutex.lock()
	var out: Array[String] = caught.duplicate()
	_mutex.unlock()
	return out


func _log_error(function: String, _file: String, _line: int, code: String, rationale: String, _editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	if error_type == ERROR_TYPE_WARNING and not warnings:
		return
	_mutex.lock()
	caught.append("%s: %s" % [function, rationale if rationale != "" else code])
	_mutex.unlock()


func _log_message(_message: String, _error: bool) -> void:
	pass
