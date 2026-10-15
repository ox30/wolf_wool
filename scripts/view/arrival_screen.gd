class_name ArrivalScreen
extends CanvasLayer
## Compares the herd with the race target, and offers to play again.

@onready var _panel: Control = %Panel
@onready var _title: Label = %Title
@onready var _message: Label = %Message
@onready var _stars: StarRow = %Stars
@onready var _arrived: Label = %Arrived
@onready var _target: Label = %Target
@onready var _replay: Button = %ReplayButton


func _ready() -> void:
	hide()
	_replay.text = tr("ARRIVAL_REPLAY")
	_replay.pressed.connect(_on_replay_pressed)


func show_result(result: RaceResult) -> void:
	match result.failure:
		RaceResult.Failure.BRIDGE_COLLAPSED:
			_title.text = tr("ARRIVAL_TITLE_BRIDGE_COLLAPSED")
			_message.text = tr("ARRIVAL_MESSAGE_BRIDGE_COLLAPSED")
		RaceResult.Failure.HERD_LOST:
			_title.text = tr("ARRIVAL_TITLE_HERD_LOST")
			_message.text = tr("ARRIVAL_MESSAGE_HERD_LOST")
		_:
			_title.text = tr("ARRIVAL_TITLE_STARS_%d" % result.stars)
			_message.text = ""
	_message.visible = not _message.text.is_empty()
	_stars.filled = result.stars
	_arrived.text = tr("ARRIVAL_ARRIVED") % result.arrived
	_target.text = tr("ARRIVAL_TARGET") % result.target
	show()
	_panel.pivot_offset = _panel.size / 2.0
	_panel.scale = Vector2.ONE * 0.8
	create_tween().tween_property(_panel, "scale", Vector2.ONE, 0.3) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()
