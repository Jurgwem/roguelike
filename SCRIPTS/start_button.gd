extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	$FPS.text = str("FPS: ", Engine.get_frames_per_second());
	pass

func _on_button_button_down() -> void:
	print("test")
	get_tree().change_scene_to_file("res://SCENES/game.tscn")
	pass # Replace with function body.
