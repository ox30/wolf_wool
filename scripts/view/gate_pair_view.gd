class_name GatePairView
extends Node3D
## Two coloured gates showing their operation, e.g. "+5" and "×2".

const WIDTH: float = 3.6
const HEIGHT: float = 2.4
const POST_COLOR := Color("#f4efe6")

var _panels: Dictionary = {}  # Lane.Side -> MeshInstance3D


func setup(pair: GatePair, styles: Dictionary, lane_x: float) -> void:
	var post_mat: StandardMaterial3D = Props.material(POST_COLOR)
	for side: Lane.Side in [Lane.Side.LEFT, Lane.Side.RIGHT]:
		var gate: GateOp = pair.gate_for(side)
		var style: Dictionary = styles.get(gate.kind_id(), {})
		var color := Color.from_string(str(style.get("color", "#ffffff")), Color.WHITE)
		var x: float = -lane_x if side == Lane.Side.LEFT else lane_x
		var panel_mat: StandardMaterial3D = Props.material(Color(color, 0.55))
		_panels[side] = Props.box(self, Vector3(WIDTH, HEIGHT, 0.08), panel_mat, Vector3(x, HEIGHT / 2.0, 0.0))
		for post_x: float in [x - WIDTH / 2.0, x + WIDTH / 2.0]:
			Props.box(self, Vector3(0.18, HEIGHT + 0.3, 0.18), post_mat, Vector3(post_x, (HEIGHT + 0.3) / 2.0, 0.0))
		var text: String = "%s%d" % [style.get("symbol", "?"), gate.value]
		var label: Label3D = Props.label(self, text, 200, Vector3(x, HEIGHT * 0.55, 0.08), Color.WHITE)
		label.modulate = color.darkened(0.6)


## Flashes the gate the herd went through and fades the other one.
func reveal_choice(side: Lane.Side) -> void:
	for panel_side: Lane.Side in _panels:
		var panel: MeshInstance3D = _panels[panel_side]
		var mat: StandardMaterial3D = panel.material_override
		var tween: Tween = create_tween()
		if panel_side == side:
			tween.tween_property(mat, "albedo_color:a", 0.95, 0.12)
			tween.tween_property(mat, "albedo_color:a", 0.0, 0.6)
		else:
			tween.tween_property(mat, "albedo_color:a", 0.15, 0.3)
