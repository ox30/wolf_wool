extends Node3D
## Drives the race scene: herd movement, swipes, obstacles and arrival.
## All rules are delegated to RaceRules; this script only shows them.

enum State { READY, RUNNING, FINISHING, DONE }

const LANE_X: float = 2.2
const LATERAL_SPEED: float = 10.0
## Horizontal drag, in viewport pixels, that counts as a swipe.
const SWIPE_THRESHOLD: float = 60.0
const CAMERA_OFFSET := Vector3(0.0, 8.0, 8.5)
const CAMERA_PITCH_DEG: float = -38.0
const RESULT_DELAY: float = 1.8
## Longer pause after a failure, to see the sheep reach the bank.
const FAILURE_RESULT_DELAY: float = 2.8
const SCENERY_WIDTH: float = 70.0
const FINISH_DISTANCE: float = 8.0

@export_file("*.json") var level_path: String = "res://data/levels/level_01.json"
@export_file("*.json") var gate_styles_path: String = "res://data/gates.json"

var _state: State = State.READY
var _level: RaceLevel
var _rules: RaceRules
var _obstacle_views: Array[Node3D] = []
var _obstacle_z: Array[float] = []
var _finish_z: float = 0.0
var _target_x: float = -LANE_X
var _touch_start: Vector2 = Vector2.ZERO
var _touching: bool = false

@onready var _flock: Flock = $Flock
@onready var _camera: Camera3D = $Camera3D
@onready var _hud: Hud = $Hud
@onready var _arrival: ArrivalScreen = $ArrivalScreen


func _ready() -> void:
	_level = LevelLoader.load_file(level_path)
	if _level == null:
		return
	_rules = RaceRules.new(_level)
	_flock.position = Vector3(_target_x, 0.0, 0.0)
	_flock.setup(_level.start_count)
	_build_track()
	_camera.rotation_degrees = Vector3(CAMERA_PITCH_DEG, 0.0, 0.0)
	_follow_camera(1.0)
	_hud.show_ready(tr(_level.title_key), _level.start_count, _level.target)


func _process(delta: float) -> void:
	if _state == State.RUNNING or (_state == State.FINISHING and _rules.failure == RaceResult.Failure.NONE):
		var speed: float = _level.speed if _state == State.RUNNING else _level.speed * 0.4
		_flock.position.z -= speed * delta
		_flock.position.x = move_toward(_flock.position.x, _target_x, LATERAL_SPEED * delta)
	if _state == State.RUNNING:
		while not _rules.is_over() and _flock.position.z <= _obstacle_z[_rules.next_index]:
			_resolve_next_obstacle()
		if _state == State.RUNNING and _rules.is_over() and _flock.position.z <= _finish_z:
			_finish()
	_follow_camera(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		_touching = touch.pressed
		_touch_start = touch.position
		if touch.pressed and _state == State.READY:
			_start()
	elif event is InputEventScreenDrag and _touching and _state == State.RUNNING:
		var drag: InputEventScreenDrag = event
		var dx: float = drag.position.x - _touch_start.x
		if absf(dx) >= SWIPE_THRESHOLD:
			_set_side(Lane.Side.RIGHT if dx > 0.0 else Lane.Side.LEFT)
			_touch_start = drag.position
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		if _state == State.READY:
			_start()
		_set_side(Lane.Side.LEFT if event.is_action_pressed("ui_left") else Lane.Side.RIGHT)
	elif event.is_action_pressed("ui_accept") and _state == State.READY:
		_start()


func _start() -> void:
	_state = State.RUNNING
	_hud.hide_ready()


func _set_side(side: Lane.Side) -> void:
	_target_x = -LANE_X if side == Lane.Side.LEFT else LANE_X


## The herd goes through the gate on the side where it actually is.
func _current_side() -> Lane.Side:
	return Lane.Side.LEFT if _flock.position.x < 0.0 else Lane.Side.RIGHT


func _resolve_next_obstacle() -> void:
	var view: Node3D = _obstacle_views[_rules.next_index]
	var side: Lane.Side = _current_side()
	var outcome: ObstacleOutcome = _rules.resolve_next(side)
	if view is GatePairView:
		(view as GatePairView).reveal_choice(side)
	elif view is BridgeView and outcome.collapsed:
		(view as BridgeView).collapse()
	_flock.apply_outcome(outcome, self)
	_hud.set_count(outcome.after)
	_show_outcome_toast(outcome)
	if _rules.failure != RaceResult.Failure.NONE:
		_finish()


func _show_outcome_toast(outcome: ObstacleOutcome) -> void:
	if outcome.collapsed:
		_hud.toast(tr("TOAST_BRIDGE_COLLAPSED"))
	elif outcome.overflow_loss > 0:
		_hud.toast(tr("TOAST_STONE_BRIDGE_OVERFLOW") % outcome.overflow_loss)
	elif outcome.rounding_loss == 1:
		_hud.toast(tr("TOAST_DIVISION_REMAINDER_ONE"))
	elif outcome.rounding_loss > 1:
		_hud.toast(tr("TOAST_DIVISION_REMAINDER_MANY") % outcome.rounding_loss)


func _finish() -> void:
	_state = State.FINISHING
	var delay: float = RESULT_DELAY if _rules.failure == RaceResult.Failure.NONE else FAILURE_RESULT_DELAY
	await get_tree().create_timer(delay).timeout
	_state = State.DONE
	_hud.hide()
	_arrival.show_result(_rules.result())


func _follow_camera(delta: float) -> void:
	var target: Vector3 = Vector3(_flock.position.x * 0.35, 0.0, _flock.position.z) + CAMERA_OFFSET
	_camera.position = _camera.position.lerp(target, 1.0 - exp(-8.0 * delta))


func _build_track() -> void:
	var errors: Array[String] = []
	var styles: Variant = LevelLoader.read_json(gate_styles_path, errors)
	if not styles is Dictionary:
		push_error("%s: %s" % [gate_styles_path, errors])
		styles = {}

	for i: int in _level.obstacles.size():
		var z: float = -(i + 1) * _level.spacing
		var obstacle: Obstacle = _level.obstacles[i]
		var view: Node3D
		if obstacle is GatePair:
			var gate_view := GatePairView.new()
			gate_view.setup(obstacle as GatePair, styles, LANE_X)
			view = gate_view
		elif obstacle is Bridge:
			var bridge_view := BridgeView.new()
			bridge_view.setup(obstacle as Bridge, SCENERY_WIDTH)
			view = bridge_view
		view.position.z = z
		add_child(view)
		_obstacle_views.append(view)
		_obstacle_z.append(z)

	var last_z: float = -_level.obstacles.size() * _level.spacing
	_finish_z = last_z - _level.spacing * 0.5 - FINISH_DISTANCE
	Scenery.build(self, 30.0, _finish_z - 60.0, _finish_z, SCENERY_WIDTH)
