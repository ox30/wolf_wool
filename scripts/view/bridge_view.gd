class_name BridgeView
extends Node3D
## A river crossed by a wooden or stone bridge, with a sign giving its limit.

const RIVER_COLOR := Color("#7fb7d6")
const WOOD_COLOR := Color("#a8743f")
const STONE_COLOR := Color("#a3a19b")
const DECK_SIZE := Vector3(6.4, 0.3, 6.0)
const RIVER_WIDTH: float = 5.0

var _structure := Node3D.new()


func setup(bridge: Bridge, scenery_width: float) -> void:
	var river_mat: StandardMaterial3D = Props.material(RIVER_COLOR, 0.2)
	Props.box(self, Vector3(scenery_width, 0.04, RIVER_WIDTH), river_mat, Vector3(0.0, 0.03, 0.0))

	var wooden: bool = bridge.kind == Bridge.Kind.WOOD
	var deck_mat: StandardMaterial3D = Props.material(WOOD_COLOR if wooden else STONE_COLOR)
	add_child(_structure)
	Props.box(_structure, DECK_SIZE, deck_mat, Vector3(0.0, DECK_SIZE.y / 2.0, 0.0))
	for x: float in [-DECK_SIZE.x / 2.0, DECK_SIZE.x / 2.0]:
		Props.box(_structure, Vector3(0.2, 0.5, DECK_SIZE.z), deck_mat, Vector3(x, 0.55, 0.0))
	if wooden:
		# Planks across the deck make the wood easy to tell from stone.
		var plank_mat: StandardMaterial3D = Props.material(WOOD_COLOR.darkened(0.25))
		for i: int in 6:
			var z: float = -DECK_SIZE.z / 2.0 + 0.5 + i * (DECK_SIZE.z - 1.0) / 5.0
			Props.box(_structure, Vector3(DECK_SIZE.x, 0.04, 0.08), plank_mat, Vector3(0.0, DECK_SIZE.y + 0.01, z))

	# Banner over the bridge entrance, readable from afar.
	var entrance_z: float = DECK_SIZE.z / 2.0 + 0.3
	var post_mat: StandardMaterial3D = Props.material(WOOD_COLOR.darkened(0.3))
	for x: float in [-DECK_SIZE.x / 2.0, DECK_SIZE.x / 2.0]:
		Props.box(self, Vector3(0.22, 3.6, 0.22), post_mat, Vector3(x, 1.8, entrance_z))
	Props.box(self, Vector3(DECK_SIZE.x + 0.4, 0.9, 0.1), Props.material(Color("#fbf7ef")), Vector3(0.0, 3.3, entrance_z))
	var key: String = "BRIDGE_WOOD_SIGN" if wooden else "BRIDGE_STONE_SIGN"
	var sign_label: Label3D = Props.label(self, tr(key) % bridge.max_count, 100, Vector3(0.0, 3.3, entrance_z + 0.06), Color.WHITE)
	sign_label.modulate = Color("#3b3a36")


## The wooden deck breaks and sinks into the river.
func collapse() -> void:
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(_structure, "position:y", -0.8, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(_structure, "rotation:z", deg_to_rad(12.0), 0.9)
	tween.tween_property(_structure, "rotation:x", deg_to_rad(-6.0), 0.9)
