extends Area3D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(other: Area3D) -> void:
	print(other.name)
