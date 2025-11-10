extends Control

## Main scene - Entry point for the app
## Loads the Home screen to start the flow

func _ready() -> void:
	# Load Home screen (deferred to avoid removal errors)
	call_deferred("_load_home")

func _load_home() -> void:
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
