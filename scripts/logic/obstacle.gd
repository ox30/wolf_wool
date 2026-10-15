class_name Obstacle
extends RefCounted
## Base class for everything the herd goes through during a race.

## Returns what happens to a herd of `count` sheep coming from `side`.
@warning_ignore("unused_parameter")
func resolve(count: int, side: Lane.Side) -> ObstacleOutcome:
	push_error("Obstacle.resolve() must be overridden.")
	return ObstacleOutcome.new(count)
