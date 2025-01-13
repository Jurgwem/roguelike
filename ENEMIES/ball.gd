extends CharacterBody2D

@onready var player : Node2D = get_node("/root/game/player");

const SPEED = 300.0


func _physics_process(delta: float) -> void:
	look_at(player.position)
	velocity.
	# Add the gravity.
	

	

	move_and_slide()
