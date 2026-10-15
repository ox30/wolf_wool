class_name TestCase
extends RefCounted
## Minimal base class for tests run by tests/run_tests.gd.

var failures: Array[String] = []


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	var numbers: bool = (actual is int or actual is float) and (expected is int or expected is float)
	if (typeof(actual) != typeof(expected) and not numbers) or actual != expected:
		failures.append("%sexpected %s, got %s" % [_prefix(message), var_to_str(expected), var_to_str(actual)])


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append("%sexpected true" % _prefix(message))


func assert_false(condition: bool, message: String = "") -> void:
	assert_true(not condition, message)


func _prefix(message: String) -> String:
	return "" if message.is_empty() else message + ": "
