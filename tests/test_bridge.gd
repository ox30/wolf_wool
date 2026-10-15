extends TestCase


func test_wood_holds_up_to_max() -> void:
	var bridge := Bridge.new(Bridge.Kind.WOOD, 20)
	for count: int in [19, 20]:
		var outcome: ObstacleOutcome = bridge.resolve(count, Lane.Side.LEFT)
		assert_false(outcome.collapsed, "count %d" % count)
		assert_eq(outcome.after, count)


func test_wood_collapses_above_max() -> void:
	var outcome: ObstacleOutcome = Bridge.new(Bridge.Kind.WOOD, 20).resolve(21, Lane.Side.LEFT)
	assert_true(outcome.collapsed)
	assert_eq(outcome.after, 0)


func test_stone_holds_up_to_max() -> void:
	var bridge := Bridge.new(Bridge.Kind.STONE, 40)
	for count: int in [39, 40]:
		var outcome: ObstacleOutcome = bridge.resolve(count, Lane.Side.RIGHT)
		assert_eq(outcome.after, count)
		assert_eq(outcome.overflow_loss, 0)


func test_stone_brings_herd_back_to_max() -> void:
	var outcome: ObstacleOutcome = Bridge.new(Bridge.Kind.STONE, 40).resolve(55, Lane.Side.RIGHT)
	assert_false(outcome.collapsed)
	assert_eq(outcome.after, 40)
	assert_eq(outcome.overflow_loss, 15)
