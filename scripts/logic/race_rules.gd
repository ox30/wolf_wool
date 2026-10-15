class_name RaceRules
extends RefCounted
## Runs a race step by step, without any scene: the view tells which side
## the herd is on, the rules say what happens.

var level: RaceLevel
var count: int
var next_index: int = 0
var failure: RaceResult.Failure = RaceResult.Failure.NONE


func _init(p_level: RaceLevel) -> void:
	level = p_level
	count = level.start_count


func is_over() -> bool:
	return failure != RaceResult.Failure.NONE or next_index >= level.obstacles.size()


func next_obstacle() -> Obstacle:
	return null if is_over() else level.obstacles[next_index]


## Resolves the next obstacle with the herd on `side`.
func resolve_next(side: Lane.Side) -> ObstacleOutcome:
	assert(not is_over(), "The race is already over.")
	var outcome: ObstacleOutcome = level.obstacles[next_index].resolve(count, side)
	next_index += 1
	count = outcome.after
	if outcome.collapsed:
		failure = RaceResult.Failure.BRIDGE_COLLAPSED
	elif count <= 0:
		failure = RaceResult.Failure.HERD_LOST
	return outcome


func result() -> RaceResult:
	return RaceResult.new(count, level.target, failure, level.star_tolerances)
