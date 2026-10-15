class_name Sheep
extends Node3D
## A placeholder sheep made of primitive shapes. It follows its slot in the
## flock and can leave the flock with a small animation (never violent).

enum Leave { FLEE, STRAY, FALL }

const FOLLOW_SHARPNESS: float = 6.0
const HOP_HEIGHT: float = 0.07
const HOP_SPEED: float = 9.0

static var _body_mesh: CapsuleMesh
static var _head_mesh: BoxMesh
static var _leg_mesh: BoxMesh
static var _wool: StandardMaterial3D
static var _skin: StandardMaterial3D

## Position the sheep walks towards, relative to the flock.
var slot: Vector3 = Vector3.ZERO
var _visual := Node3D.new()
var _time: float = randf() * TAU
var _leaving: bool = false


func _ready() -> void:
	_ensure_shared_resources()
	add_child(_visual)
	_add_part(_body_mesh, _wool, Vector3(0.0, 0.32, 0.0), Vector3(90.0, 0.0, 0.0))
	_add_part(_head_mesh, _skin, Vector3(0.0, 0.42, -0.3), Vector3.ZERO)
	for x: float in [-0.09, 0.09]:
		for z: float in [-0.12, 0.12]:
			_add_part(_leg_mesh, _skin, Vector3(x, 0.08, z), Vector3.ZERO)


func _process(delta: float) -> void:
	_time += delta
	_visual.position.y = absf(sin(_time * HOP_SPEED)) * HOP_HEIGHT
	if not _leaving:
		position = position.lerp(slot, 1.0 - exp(-FOLLOW_SHARPNESS * delta))


## Grows from nothing, for sheep that join the flock.
func pop_in() -> void:
	scale = Vector3.ONE * 0.01
	create_tween().tween_property(self, "scale", Vector3.ONE, 0.35) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Leaves the flock: the sheep is moved to `world` so it stays behind while
## the flock walks on, plays its animation, then disappears.
func leave(style: Leave, world: Node3D, side_sign: float) -> void:
	_leaving = true
	reparent(world)
	var start: Vector3 = global_position
	var tween: Tween = create_tween()
	match style:
		Leave.FLEE:
			var target: Vector3 = start + Vector3(side_sign * randf_range(5.0, 8.0), 0.0, randf_range(2.0, 5.0))
			look_at(target, Vector3.UP)
			tween.tween_property(self, "global_position", target, 1.2)
		Leave.STRAY:
			var mark := Label3D.new()
			mark.text = "?"
			mark.font_size = 96
			mark.pixel_size = 0.006
			mark.outline_size = 18
			mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			mark.position = Vector3(0.0, 0.95, 0.0)
			add_child(mark)
			var target: Vector3 = start + Vector3(side_sign * 3.5, 0.0, 3.0)
			look_at(target, Vector3.UP)
			tween.tween_property(self, "global_position", target, 2.4) \
					.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		Leave.FALL:
			# Slides into the water, then swims back to the bank.
			var in_water: Vector3 = start + Vector3(side_sign * 1.0, -0.3, 0.5)
			tween.tween_property(self, "global_position", in_water, 0.5).set_ease(Tween.EASE_IN)
			tween.tween_property(self, "global_position", in_water + Vector3(side_sign * 7.0, 0.0, 0.0), 2.0)
	tween.tween_property(self, "scale", Vector3.ONE * 0.01, 0.35)
	tween.tween_callback(queue_free)


func _add_part(mesh: Mesh, material: Material, offset: Vector3, rotation_deg: Vector3) -> void:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.material_override = material
	part.position = offset
	part.rotation_degrees = rotation_deg
	_visual.add_child(part)


static func _ensure_shared_resources() -> void:
	if _body_mesh != null:
		return
	_body_mesh = CapsuleMesh.new()
	_body_mesh.radius = 0.17
	_body_mesh.height = 0.52
	_body_mesh.radial_segments = 10
	_body_mesh.rings = 4
	_head_mesh = BoxMesh.new()
	_head_mesh.size = Vector3(0.14, 0.16, 0.18)
	_leg_mesh = BoxMesh.new()
	_leg_mesh.size = Vector3(0.05, 0.16, 0.05)
	_wool = StandardMaterial3D.new()
	_wool.albedo_color = Color("#f7f3ea")
	_wool.roughness = 1.0
	_skin = StandardMaterial3D.new()
	_skin.albedo_color = Color("#3d3631")
