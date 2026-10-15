class_name GatePair
extends Obstacle
## Two gates side by side; the herd goes through the one on its side.

var left: GateOp
var right: GateOp


func _init(p_left: GateOp, p_right: GateOp) -> void:
	left = p_left
	right = p_right


func gate_for(side: Lane.Side) -> GateOp:
	return left if side == Lane.Side.LEFT else right


func resolve(count: int, side: Lane.Side) -> ObstacleOutcome:
	return gate_for(side).apply(count)
