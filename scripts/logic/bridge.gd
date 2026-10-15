class_name Bridge
extends Obstacle
## A bridge that only carries a limited number of sheep.
## Wood collapses (race lost); stone holds but the extra sheep fall off.

enum Kind { WOOD, STONE }

const KIND_IDS: Dictionary = {
	"wood": Kind.WOOD,
	"stone": Kind.STONE,
}

var kind: Kind
var max_count: int


func _init(p_kind: Kind, p_max_count: int) -> void:
	kind = p_kind
	max_count = p_max_count


func kind_id() -> String:
	return KIND_IDS.find_key(kind)


@warning_ignore("unused_parameter")
func resolve(count: int, side: Lane.Side) -> ObstacleOutcome:
	var outcome := ObstacleOutcome.new(count)
	if count <= max_count:
		return outcome
	match kind:
		Kind.WOOD:
			outcome.collapsed = true
			outcome.after = 0
		Kind.STONE:
			outcome.after = max_count
			outcome.overflow_loss = count - max_count
	return outcome
