extends SceneTree
## Runs every test_*() method of every tests/test_*.gd script.
## A script that does not compile, or an engine/script error raised during a
## test, counts as a failure.
## Usage: godot --headless --path . -s tests/run_tests.gd

const TEST_DIR: String = "res://tests/"


## Collects errors reported by the engine while a test runs.
class ErrorCollector:
	extends Logger

	var errors: Array[String] = []
	var _mutex := Mutex.new()

	@warning_ignore("unused_parameter")
	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
		_mutex.lock()
		errors.append("%s (%s:%d)" % [rationale if not rationale.is_empty() else code, file, line])
		_mutex.unlock()

	func take() -> Array[String]:
		_mutex.lock()
		var taken: Array[String] = errors.duplicate()
		errors.clear()
		_mutex.unlock()
		return taken


func _init() -> void:
	var collector := ErrorCollector.new()
	OS.add_logger(collector)
	var total: int = 0
	var failed: int = 0
	for file: String in DirAccess.get_files_at(TEST_DIR):
		if not (file.begins_with("test_") and file.ends_with(".gd")) or file == "test_case.gd":
			continue
		var script: GDScript = load(TEST_DIR + file)
		var load_errors: Array[String] = collector.take()
		if script == null or not script.can_instantiate() or not load_errors.is_empty():
			total += 1
			failed += 1
			print("  FAIL  %s does not compile" % file)
			continue
		for method: Dictionary in script.get_script_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			total += 1
			var test: TestCase = script.new()
			test.call(method_name)
			var failures: Array[String] = test.failures + collector.take()
			if failures.is_empty():
				print("  ok    %s.%s" % [file.get_basename(), method_name])
			else:
				failed += 1
				print("  FAIL  %s.%s" % [file.get_basename(), method_name])
				for failure: String in failures:
					print("        " + failure)
	OS.remove_logger(collector)
	print("\n%d tests, %d failed" % [total, failed])
	quit(1 if failed > 0 or total == 0 else 0)
