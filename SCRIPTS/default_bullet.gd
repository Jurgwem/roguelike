extends Node2D

@onready var player = get_node("/root/game/player");

var damage = 10;
var speed = 16;
var inaccuracy = 4; #overall degrees, aka spread

var lifetime = 0;
var maxLifetime = 250;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = player.position;
	look_at(get_global_mouse_position())
	rotation -= deg_to_rad((randf()*inaccuracy) - (inaccuracy / 2))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(speed, 0).rotated(rotation)
	lifetime += 1;
	if lifetime >= maxLifetime:
		queue_free();
	pass
