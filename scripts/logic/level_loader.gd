class_name LevelLoader
extends RefCounted
## Builds a RaceLevel from a JSON file, checking every field.


## Returns null and reports errors with push_error() if the file is invalid.
static func load_file(path: String) -> RaceLevel:
	var errors: Array[String] = []
	var level: RaceLevel = parse(read_json(path, errors), errors)
	for error: String in errors:
		push_error("%s: %s" % [path, error])
	return level if errors.is_empty() else null


static func read_json(path: String, errors: Array[String]) -> Variant:
	var text: String = FileAccess.get_file_as_string(path)
	if text.is_empty():
		errors.append("cannot read file")
		return null
	var json := JSON.new()
	if json.parse(text) != OK:
		errors.append("invalid JSON at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		return null
	return json.data


## Fills `errors` and returns null when `data` is not a valid level.
static func parse(data: Variant, errors: Array[String]) -> RaceLevel:
	if not data is Dictionary:
		errors.append("level must be an object")
		return null
	var dict: Dictionary = data
	var level := RaceLevel.new()
	level.id = _read_string(dict, "id", errors)
	level.title_key = _read_string(dict, "title_key", errors)
	level.start_count = _read_int(dict, "start", 1, errors)
	level.target = _read_int(dict, "target", 1, errors)
	level.speed = _read_float(dict, "speed", errors)
	level.spacing = _read_float(dict, "spacing", errors)
	if dict.has("star_tolerances"):
		level.star_tolerances = _read_tolerances(dict["star_tolerances"], errors)

	var raw_obstacles: Variant = dict.get("obstacles")
	if not raw_obstacles is Array or (raw_obstacles as Array).is_empty():
		errors.append("'obstacles' must be a non-empty array")
	else:
		var index: int = 0
		for raw: Variant in raw_obstacles:
			var obstacle: Obstacle = _parse_obstacle(raw, "obstacles[%d]" % index, errors)
			if obstacle != null:
				level.obstacles.append(obstacle)
			index += 1
	return level if errors.is_empty() else null


static func _parse_obstacle(raw: Variant, where: String, errors: Array[String]) -> Obstacle:
	if not raw is Dictionary:
		errors.append("%s must be an object" % where)
		return null
	var dict: Dictionary = raw
	match dict.get("type"):
		"gates":
			var left: GateOp = _parse_gate(dict.get("left"), where + ".left", errors)
			var right: GateOp = _parse_gate(dict.get("right"), where + ".right", errors)
			return GatePair.new(left, right) if left != null and right != null else null
		"bridge":
			var kind_id: Variant = dict.get("kind")
			if not Bridge.KIND_IDS.has(kind_id):
				errors.append("%s.kind must be one of %s" % [where, Bridge.KIND_IDS.keys()])
				return null
			var max_count: int = _read_int(dict, "max", 1, errors, where)
			return Bridge.new(Bridge.KIND_IDS[kind_id], max_count)
		_:
			errors.append("%s.type must be 'gates' or 'bridge'" % where)
			return null


static func _parse_gate(raw: Variant, where: String, errors: Array[String]) -> GateOp:
	if not raw is Dictionary:
		errors.append("%s must be an object" % where)
		return null
	var dict: Dictionary = raw
	var op: Variant = dict.get("op")
	if not GateOp.KIND_IDS.has(op):
		errors.append("%s.op must be one of %s" % [where, GateOp.KIND_IDS.keys()])
		return null
	var kind: GateOp.Kind = GateOp.KIND_IDS[op]
	var minimum: int = 2 if kind == GateOp.Kind.DIV else 1
	var value: int = _read_int(dict, "value", minimum, errors, where)
	return GateOp.new(kind, value)


static func _read_string(dict: Dictionary, key: String, errors: Array[String]) -> String:
	var value: Variant = dict.get(key)
	if not value is String or (value as String).is_empty():
		errors.append("'%s' must be a non-empty string" % key)
		return ""
	return value


## JSON numbers are floats: accept them only when they hold a whole number.
static func _read_int(dict: Dictionary, key: String, minimum: int, errors: Array[String], where: String = "") -> int:
	var value: Variant = dict.get(key)
	var label: String = key if where.is_empty() else "%s.%s" % [where, key]
	if not (value is int or value is float) or float(value) != floorf(float(value)) or int(value) < minimum:
		errors.append("'%s' must be a whole number >= %d" % [label, minimum])
		return minimum
	return int(value)


static func _read_float(dict: Dictionary, key: String, errors: Array[String]) -> float:
	var value: Variant = dict.get(key)
	if not (value is int or value is float) or float(value) <= 0.0:
		errors.append("'%s' must be a number > 0" % key)
		return 1.0
	return float(value)


static func _read_tolerances(raw: Variant, errors: Array[String]) -> Array[float]:
	var tolerances: Array[float] = []
	if not raw is Array:
		errors.append("'star_tolerances' must be an array")
		return tolerances
	var previous: float = 0.0
	for value: Variant in raw:
		if not (value is int or value is float) or float(value) <= previous:
			errors.append("'star_tolerances' must hold increasing numbers > 0")
			return tolerances
		previous = float(value)
		tolerances.append(previous)
	return tolerances
