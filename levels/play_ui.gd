class_name PlayUi
extends Control

@onready var level_name_label: Label = %LevelNameLabel
@onready var steps_count_label: Label = %StepsCountLabel
@onready var time_remaining_label: Label = %TimeRemainingLabel

const STEPS_FORMAT: String = "%04d"
const TIME_FORMAT: String = "%03d"

func set_level_name(level_name: String) -> void:
	level_name_label.text = level_name

func set_time_remaining(remaining_time: int) -> void:
	time_remaining_label.text = TIME_FORMAT % remaining_time

func set_steps(steps: int) -> void:
	steps_count_label.text = STEPS_FORMAT % steps
