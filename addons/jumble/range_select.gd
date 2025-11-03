@tool
class_name RangeSelect
extends Control

signal changed(min_value: float, max_value: float)

@onready var min_slider: HSlider = %MinSlider
@onready var max_slider: HSlider = %MaxSlider
@onready var fill_bar: ProgressBar = %FillBar

var min_value:
	get():
		return min_slider.value / min_slider.max_value

var max_value:
	get():
		return max_slider.value / max_slider.max_value

func _ready() -> void:
	min_slider.value_changed.connect(_on_min_change)
	max_slider.value_changed.connect(_on_max_change)
	_update_fill_bar()
	
func _on_min_change(value: float):
	var clamped_value = clampf(value, min_slider.min_value, max_slider.value)
	min_slider.set_value_no_signal(clamped_value)
	_update_fill_bar()
	changed.emit(min_slider.value, max_slider.value)

func _on_max_change(value: float):
	var clamped_value = clampf(value, min_slider.value, max_slider.max_value)
	max_slider.set_value_no_signal(clamped_value)
	_update_fill_bar()
	changed.emit(min_slider.value, max_slider.value)

func _update_fill_bar():
	var min_grabber_position: Vector2 = get_grabber_position(min_slider)
	var max_grabber_position: Vector2 = get_grabber_position(max_slider)
	var width: float = max_grabber_position.x - min_grabber_position.x
	fill_bar.position.x = min_grabber_position.x
	fill_bar.size.x = width
	fill_bar.visible = width > 0

static func get_grabber_position(slider: HSlider) -> Vector2:
	var ratio: float = slider.value / slider.max_value
	var x_position: float = slider.position.x + slider.size.x * ratio
	var position = Vector2(x_position, slider.position.y)
	return position
