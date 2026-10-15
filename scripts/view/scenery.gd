class_name Scenery
extends RefCounted
## Placeholder landscape: meadow, path, trees, mountains and the finish arch.

const GRASS := Color("#9ccf7a")
const PATH := Color("#e2d3a4")
const ALPINE_GRASS := Color("#b9e08f")
const TRUNK := Color("#7a5634")
const PINE := Color("#4f8a5b")
const ROCK := Color("#8f9bb0")
const SNOW := Color("#f5f7fa")
const CHALET_WALL := Color("#c98e57")
const CHALET_ROOF := Color("#7d4f3a")
const TREE_SEED: int = 7
const PLANE_CELL: float = 4.0


## Builds the scenery between z = `near_z` and z = `far_z` (negative is forward).
static func build(parent: Node3D, near_z: float, far_z: float, finish_z: float, width: float) -> void:
	var length: float = near_z - far_z
	var center_z: float = (near_z + far_z) / 2.0
	var ground: PlaneMesh = _plane(Vector2(width, length))
	Props.mesh_instance(parent, ground, Props.material(GRASS), Vector3(0.0, 0.0, center_z))
	var path: PlaneMesh = _plane(Vector2(8.6, near_z - finish_z))
	Props.mesh_instance(parent, path, Props.material(PATH), Vector3(0.0, 0.03, (near_z + finish_z) / 2.0))
	var alpage: PlaneMesh = _plane(Vector2(width, finish_z - far_z))
	Props.mesh_instance(parent, alpage, Props.material(ALPINE_GRASS), Vector3(0.0, 0.03, (finish_z + far_z) / 2.0))

	_build_trees(parent, near_z, finish_z, width)
	_build_finish(parent, finish_z)
	_build_mountains(parent, far_z)


## Mobile renderers light per vertex: big planes need vertices every few
## metres, or light and fog show up as large triangles.
static func _plane(size: Vector2) -> PlaneMesh:
	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_width = ceili(size.x / PLANE_CELL)
	plane.subdivide_depth = ceili(size.y / PLANE_CELL)
	return plane


static func _build_trees(parent: Node3D, near_z: float, finish_z: float, width: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = TREE_SEED
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.15
	trunk.bottom_radius = 0.2
	trunk.height = 1.0
	var crown := CylinderMesh.new()
	crown.top_radius = 0.0
	crown.bottom_radius = 1.1
	crown.height = 2.8
	crown.radial_segments = 8
	var trunk_mat: StandardMaterial3D = Props.material(TRUNK)
	var crown_mat: StandardMaterial3D = Props.material(PINE)
	var z: float = near_z
	while z > finish_z:
		for side: float in [-1.0, 1.0]:
			var x: float = side * rng.randf_range(7.5, width / 2.0 - 2.0)
			var size: float = rng.randf_range(0.7, 1.4)
			var tree := Node3D.new()
			tree.position = Vector3(x, 0.0, z + rng.randf_range(-3.0, 3.0))
			tree.scale = Vector3.ONE * size
			parent.add_child(tree)
			Props.mesh_instance(tree, trunk, trunk_mat, Vector3(0.0, 0.5, 0.0))
			Props.mesh_instance(tree, crown, crown_mat, Vector3(0.0, 2.3, 0.0))
		z -= 6.0


static func _build_finish(parent: Node3D, finish_z: float) -> void:
	var wood: StandardMaterial3D = Props.material(TRUNK)
	for x: float in [-4.6, 4.6]:
		Props.box(parent, Vector3(0.3, 3.6, 0.3), wood, Vector3(x, 1.8, finish_z))
	Props.box(parent, Vector3(9.8, 0.9, 0.25), Props.material(Color("#fbf7ef")), Vector3(0.0, 3.4, finish_z))
	var sign_label: Label3D = Props.label(parent, tr_static("FINISH_SIGN"), 110, Vector3(0.0, 3.4, finish_z + 0.15), Color.WHITE)
	sign_label.modulate = Color("#3b3a36")

	# A small chalet waits on the alpine meadow.
	var chalet := Node3D.new()
	chalet.position = Vector3(5.5, 0.0, finish_z - 9.0)
	parent.add_child(chalet)
	Props.box(chalet, Vector3(4.0, 2.4, 3.2), Props.material(CHALET_WALL), Vector3(0.0, 1.2, 0.0))
	var roof := PrismMesh.new()
	roof.size = Vector3(4.8, 1.5, 3.8)
	Props.mesh_instance(chalet, roof, Props.material(CHALET_ROOF), Vector3(0.0, 3.15, 0.0))


static func _build_mountains(parent: Node3D, far_z: float) -> void:
	var rock: StandardMaterial3D = Props.material(ROCK)
	var snow: StandardMaterial3D = Props.material(SNOW)
	var peaks: Array[Vector3] = [Vector3(-30, 32, 0), Vector3(0, 40, -15), Vector3(28, 30, 5), Vector3(-55, 26, 10), Vector3(55, 28, -5)]
	for peak: Vector3 in peaks:
		var mountain := CylinderMesh.new()
		mountain.top_radius = 0.0
		mountain.bottom_radius = peak.y * 0.9
		mountain.height = peak.y
		mountain.radial_segments = 7
		Props.mesh_instance(parent, mountain, rock, Vector3(peak.x, peak.y / 2.0, far_z + peak.z))
		var cap := CylinderMesh.new()
		cap.top_radius = 0.0
		cap.bottom_radius = peak.y * 0.9 * 0.25
		cap.height = peak.y * 0.25
		cap.radial_segments = 7
		Props.mesh_instance(parent, cap, snow, Vector3(peak.x, peak.y * 0.875 + 0.05, far_z + peak.z))


## Static functions have no Object to call tr() on.
static func tr_static(key: String) -> String:
	return TranslationServer.translate(key)
