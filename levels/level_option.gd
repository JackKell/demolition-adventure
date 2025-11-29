class_name LevelOption
extends Panel

@export var level_data: LevelData 

@onready var image: TextureRect = $Image
@onready var level_name_label: Label = %LevelNameLabel
@onready var completed_icon: TextureRect = %CompletedIcon

signal clicked

func _ready() -> void:
	if not level_data:
		push_error(name, "is missing level_data")
		return
	image.texture = level_data.thumbnail
	level_name_label.text = str(level_data.world) + " - " + str(level_data.stage)
	update()

func update():
	completed_icon.visible = level_data.save_data.has_completed

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit()
