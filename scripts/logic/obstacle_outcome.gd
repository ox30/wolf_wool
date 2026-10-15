class_name ObstacleOutcome
extends RefCounted
## What happened to the herd when it went through one obstacle.

## Herd size before the obstacle.
var before: int
## Herd size after the obstacle.
var after: int
## Sheep lost because a division had a remainder (they stray away).
var rounding_loss: int = 0
## Sheep that fell off an overloaded stone bridge.
var overflow_loss: int = 0
## True when a wooden bridge collapsed under the herd.
var collapsed: bool = false


func _init(p_before: int) -> void:
	before = p_before
	after = p_before


func delta() -> int:
	return after - before
