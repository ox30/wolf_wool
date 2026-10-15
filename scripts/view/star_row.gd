class_name StarRow
extends Control
## Draws the race stars as shapes, so no special font glyph is needed.

const FILLED := Color("#f2c14e")
const EMPTY := Color("#ddd6c8")
const POINTS: int = 5

var filled: int = 0:
	set(value):
		filled = value
		queue_redraw()


func _draw() -> void:
	var count: int = RaceResult.MAX_STARS
	var step: float = size.x / count
	var radius: float = minf(step, size.y) * 0.42
	for i: int in count:
		var center := Vector2(step * (i + 0.5), size.y / 2.0)
		draw_colored_polygon(_star(center, radius), FILLED if i < filled else EMPTY)


func _star(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in POINTS * 2:
		var r: float = radius if i % 2 == 0 else radius * 0.45
		var angle: float = -PI / 2.0 + i * PI / POINTS
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	return points
