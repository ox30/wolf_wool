extends TestCase

const LEVEL_PATHS: Array[String] = ["res://data/levels/level_01.json"]


func _valid_data() -> Dictionary:
	return {
		"id": "test",
		"title_key": "TEST",
		"start": 5,
		"target": 10,
		"speed": 5,
		"spacing": 20,
		"obstacles": [
			{"type": "gates", "left": {"op": "add", "value": 5}, "right": {"op": "div", "value": 2}},
			{"type": "bridge", "kind": "stone", "max": 12},
		],
	}


func test_parse_valid_level() -> void:
	var errors: Array[String] = []
	var level: RaceLevel = LevelLoader.parse(_valid_data(), errors)
	assert_eq(errors, [] as Array[String])
	assert_eq(level.start_count, 5)
	assert_eq(level.obstacles.size(), 2)
	var pair: GatePair = level.obstacles[0]
	assert_eq(pair.right.kind, GateOp.Kind.DIV)
	var bridge: Bridge = level.obstacles[1]
	assert_eq(bridge.kind, Bridge.Kind.STONE)
	assert_eq(bridge.max_count, 12)
	assert_eq(level.star_tolerances, RaceLevel.DEFAULT_STAR_TOLERANCES)


func test_reject_unknown_operation() -> void:
	var data: Dictionary = _valid_data()
	data["obstacles"][0]["left"]["op"] = "pow"
	var errors: Array[String] = []
	assert_eq(LevelLoader.parse(data, errors), null)
	assert_eq(errors.size(), 1)


func test_reject_division_by_one_and_fractions() -> void:
	var data: Dictionary = _valid_data()
	data["obstacles"][0]["right"]["value"] = 1
	data["target"] = 10.5
	var errors: Array[String] = []
	assert_eq(LevelLoader.parse(data, errors), null)
	assert_eq(errors.size(), 2)


func test_reject_missing_fields() -> void:
	var errors: Array[String] = []
	assert_eq(LevelLoader.parse({}, errors), null)
	assert_true(errors.size() >= 6)
	assert_eq(LevelLoader.parse([], errors), null)


func test_level_files_are_valid_and_reachable() -> void:
	for path: String in LEVEL_PATHS:
		var level: RaceLevel = LevelLoader.load_file(path)
		assert_true(level != null, path)
		if level != null:
			assert_true(_count_exact_paths(level) > 0, path + " has a path to the exact target")


func test_every_operation_has_a_gate_style() -> void:
	var errors: Array[String] = []
	var styles: Variant = LevelLoader.read_json("res://data/gates.json", errors)
	assert_eq(errors, [] as Array[String])
	for op: String in GateOp.KIND_IDS:
		assert_true(styles is Dictionary and (styles as Dictionary).has(op), "style for " + op)


## Plays every left/right combination and counts those that hit the target.
func _count_exact_paths(level: RaceLevel) -> int:
	var gate_count: int = level.obstacles.filter(func(o: Obstacle) -> bool: return o is GatePair).size()
	var exact: int = 0
	for mask: int in 1 << gate_count:
		var rules := RaceRules.new(level)
		var gate_index: int = 0
		while not rules.is_over():
			var side := Lane.Side.LEFT
			if rules.next_obstacle() is GatePair:
				side = Lane.Side.RIGHT if mask & (1 << gate_index) else Lane.Side.LEFT
				gate_index += 1
			rules.resolve_next(side)
		var result: RaceResult = rules.result()
		if result.is_success() and result.arrived == level.target:
			exact += 1
	return exact
