class_name Hud
extends CanvasLayer
## Herd counter, target, short messages and the start panel.

const TOAST_TIME: float = 2.2

var _toast_tween: Tween

@onready var _herd_label: Label = %HerdLabel
@onready var _target_label: Label = %TargetLabel
@onready var _toast: Label = %Toast
@onready var _start_panel: Control = %StartPanel
@onready var _start_title: Label = %StartTitle
@onready var _start_rules: Label = %StartRules
@onready var _start_tap: Label = %StartTap


func show_ready(level_title: String, count: int, target: int) -> void:
	_start_title.text = "%s\n%s" % [tr("START_TITLE"), level_title]
	_start_rules.text = tr("START_RULES")
	_start_tap.text = tr("START_TAP")
	_target_label.text = tr("HUD_TARGET") % target
	_herd_label.text = tr("HUD_HERD") % count
	_toast.modulate.a = 0.0
	_start_panel.show()


func hide_ready() -> void:
	_start_panel.hide()


func set_count(count: int) -> void:
	_herd_label.text = tr("HUD_HERD") % count
	_herd_label.pivot_offset = _herd_label.size / 2.0
	var tween: Tween = create_tween()
	tween.tween_property(_herd_label, "scale", Vector2.ONE * 1.25, 0.08)
	tween.tween_property(_herd_label, "scale", Vector2.ONE, 0.2)


func toast(text: String) -> void:
	_toast.text = text
	if _toast_tween != null:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast, "modulate:a", 1.0, 0.15)
	_toast_tween.tween_interval(TOAST_TIME)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.4)
