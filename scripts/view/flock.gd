class_name Flock
extends Node3D
## Shows the herd as small sheep. Beyond MAX_VISIBLE sheep, only the counter
## gives the exact number, to stay smooth on phones.

const MAX_VISIBLE: int = 60
const SLOT_SPACING: float = 0.36
const GOLDEN_ANGLE: float = 2.39996323
## Extra stray sheep shown when a division remainder is not visible otherwise.
const MAX_EXTRA_STRAYS: int = 3

var _sheep: Array[Sheep] = []


func setup(count: int) -> void:
	for i: int in mini(count, MAX_VISIBLE):
		var sheep: Sheep = _spawn()
		sheep.position = sheep.slot


## Updates the visible sheep after an obstacle. Lost sheep leave into `world`.
func apply_outcome(outcome: ObstacleOutcome, world: Node3D) -> void:
	var visible_after: int = mini(outcome.after, MAX_VISIBLE)
	var to_remove: int = _sheep.size() - visible_after
	if to_remove < 0:
		for i: int in -to_remove:
			var sheep: Sheep = _spawn()
			sheep.position = sheep.slot + Vector3(0.0, 0.0, 1.0)
			sheep.pop_in()
		return

	var strays: int = mini(outcome.rounding_loss, to_remove)
	var falls: int = mini(outcome.overflow_loss, to_remove - strays)
	for i: int in to_remove:
		var style: Sheep.Leave = Sheep.Leave.FLEE
		if outcome.collapsed:
			style = Sheep.Leave.FALL
		elif i < strays:
			style = Sheep.Leave.STRAY
		elif i < strays + falls:
			style = Sheep.Leave.FALL
		_release(_sheep.pop_back(), style, world)

	# A big herd may hide the remainder of a division: still show the strays.
	for i: int in mini(outcome.rounding_loss, MAX_EXTRA_STRAYS) - strays:
		var stray: Sheep = _spawn()
		stray.position = stray.slot
		_release(_sheep.pop_back(), Sheep.Leave.STRAY, world)


func _spawn() -> Sheep:
	var sheep := Sheep.new()
	sheep.slot = _slot(_sheep.size())
	sheep.rotation.y = randf_range(-0.15, 0.15)
	add_child(sheep)
	_sheep.append(sheep)
	return sheep


func _release(sheep: Sheep, style: Sheep.Leave, world: Node3D) -> void:
	var side_sign: float = signf(sheep.position.x)
	if side_sign == 0.0:
		side_sign = 1.0 if randf() < 0.5 else -1.0
	sheep.leave(style, world, side_sign)


## Sunflower layout: compact, round, and stable when sheep are added.
func _slot(index: int) -> Vector3:
	var radius: float = SLOT_SPACING * sqrt(index + 0.5)
	var angle: float = index * GOLDEN_ANGLE
	return Vector3(cos(angle) * radius * 0.85, 0.0, sin(angle) * radius * 1.15)
