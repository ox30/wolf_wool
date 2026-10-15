extends TestCase

const LEFT := Lane.Side.LEFT
const RIGHT := Lane.Side.RIGHT


func _make_level() -> RaceLevel:
	var level := RaceLevel.new()
	level.start_count = 10
	level.target = 20
	level.obstacles = [
		GatePair.new(GateOp.new(GateOp.Kind.ADD, 5), GateOp.new(GateOp.Kind.MUL, 2)),
		Bridge.new(Bridge.Kind.WOOD, 20),
		GatePair.new(GateOp.new(GateOp.Kind.SUB, 20), GateOp.new(GateOp.Kind.ADD, 5)),
	]
	return level


func test_exact_target_gives_three_stars() -> void:
	var rules := RaceRules.new(_make_level())
	rules.resolve_next(LEFT)   # 15
	rules.resolve_next(LEFT)   # bridge holds
	rules.resolve_next(RIGHT)  # 20
	assert_true(rules.is_over())
	var result: RaceResult = rules.result()
	assert_true(result.is_success())
	assert_eq(result.arrived, 20)
	assert_eq(result.stars, 3)


func test_bridge_holds_at_max() -> void:
	var rules := RaceRules.new(_make_level())
	rules.resolve_next(RIGHT)  # 20, exactly the bridge max
	rules.resolve_next(LEFT)
	rules.resolve_next(RIGHT)  # 25
	assert_true(rules.result().is_success())
	assert_eq(rules.result().arrived, 25)
	assert_eq(rules.result().stars, 1)


func test_bridge_collapse_ends_race() -> void:
	var level: RaceLevel = _make_level()
	level.start_count = 11
	var rules := RaceRules.new(level)
	rules.resolve_next(RIGHT)  # 22 > 20
	var outcome: ObstacleOutcome = rules.resolve_next(LEFT)
	assert_true(outcome.collapsed)
	assert_true(rules.is_over())
	assert_eq(rules.result().failure, RaceResult.Failure.BRIDGE_COLLAPSED)
	assert_eq(rules.result().arrived, 0)
	assert_eq(rules.result().stars, 0)


func test_empty_herd_ends_race() -> void:
	var rules := RaceRules.new(_make_level())
	rules.resolve_next(LEFT)   # 15
	rules.resolve_next(LEFT)
	rules.resolve_next(LEFT)   # 0
	assert_eq(rules.result().failure, RaceResult.Failure.HERD_LOST)


func test_next_obstacle_is_null_when_over() -> void:
	var rules := RaceRules.new(_make_level())
	assert_true(rules.next_obstacle() is GatePair)
	for i: int in 3:
		rules.resolve_next(LEFT if i < 2 else RIGHT)
	assert_eq(rules.next_obstacle(), null)


func test_stars_scale() -> void:
	var tolerances: Array[float] = [0.10, 0.25]
	assert_eq(RaceResult.compute_stars(40, 40, tolerances), 3)
	assert_eq(RaceResult.compute_stars(44, 40, tolerances), 2)
	assert_eq(RaceResult.compute_stars(36, 40, tolerances), 2)
	assert_eq(RaceResult.compute_stars(45, 40, tolerances), 1)
	assert_eq(RaceResult.compute_stars(30, 40, tolerances), 1)
	assert_eq(RaceResult.compute_stars(29, 40, tolerances), 0)
	assert_eq(RaceResult.compute_stars(80, 40, tolerances), 0)
