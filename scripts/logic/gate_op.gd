class_name GateOp
extends RefCounted
## One arithmetic gate: applies + − × ÷ to the herd size.

enum Kind { ADD, SUB, MUL, DIV }

## Identifiers used in data files.
const KIND_IDS: Dictionary = {
	"add": Kind.ADD,
	"sub": Kind.SUB,
	"mul": Kind.MUL,
	"div": Kind.DIV,
}

var kind: Kind
var value: int


func _init(p_kind: Kind, p_value: int) -> void:
	kind = p_kind
	value = p_value


func kind_id() -> String:
	return KIND_IDS.find_key(kind)


## Subtraction never goes below zero; division rounds down and the
## remainder is reported as sheep that stray away.
func apply(count: int) -> ObstacleOutcome:
	var outcome := ObstacleOutcome.new(count)
	match kind:
		Kind.ADD:
			outcome.after = count + value
		Kind.SUB:
			outcome.after = maxi(count - value, 0)
		Kind.MUL:
			outcome.after = count * value
		Kind.DIV:
			@warning_ignore("integer_division")
			outcome.after = count / value
			outcome.rounding_loss = count % value
	return outcome
