extends TestCase


func test_add() -> void:
	assert_eq(GateOp.new(GateOp.Kind.ADD, 5).apply(10).after, 15)


func test_sub() -> void:
	assert_eq(GateOp.new(GateOp.Kind.SUB, 4).apply(10).after, 6)


func test_sub_never_below_zero() -> void:
	assert_eq(GateOp.new(GateOp.Kind.SUB, 12).apply(10).after, 0)


func test_mul() -> void:
	assert_eq(GateOp.new(GateOp.Kind.MUL, 3).apply(7).after, 21)


func test_div_exact_has_no_rounding_loss() -> void:
	var outcome: ObstacleOutcome = GateOp.new(GateOp.Kind.DIV, 2).apply(10)
	assert_eq(outcome.after, 5)
	assert_eq(outcome.rounding_loss, 0)


func test_div_rounds_down_and_reports_strays() -> void:
	var outcome: ObstacleOutcome = GateOp.new(GateOp.Kind.DIV, 3).apply(11)
	assert_eq(outcome.after, 3)
	assert_eq(outcome.rounding_loss, 2)


func test_shrinking_operations_keep_empty_herd_empty() -> void:
	for kind: GateOp.Kind in [GateOp.Kind.SUB, GateOp.Kind.MUL, GateOp.Kind.DIV]:
		assert_eq(GateOp.new(kind, 2).apply(0).after, 0, GateOp.KIND_IDS.find_key(kind))


func test_outcome_keeps_before() -> void:
	var outcome: ObstacleOutcome = GateOp.new(GateOp.Kind.ADD, 3).apply(4)
	assert_eq(outcome.before, 4)
	assert_eq(outcome.delta(), 3)


func test_gate_pair_uses_side() -> void:
	var pair := GatePair.new(GateOp.new(GateOp.Kind.ADD, 1), GateOp.new(GateOp.Kind.MUL, 10))
	assert_eq(pair.resolve(5, Lane.Side.LEFT).after, 6)
	assert_eq(pair.resolve(5, Lane.Side.RIGHT).after, 50)
