extends Node2D

var damage : int = 10;
var speed : int = 16;
var inaccuracy : float = 4; #overall degrees, aka spread

var lifetime : int = 0;
var maxLifetime : int = 250;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().name == "Start":
		speed = 4;
		inaccuracy = 1;
		scale = Vector2(0.7, 0.7);
		position = get_node("/root/Start/startPlayer").position;
		position += Vector2(0, -2.3);
	else:
		var player : Node2D = get_node("/root/game/player");
		position = player.position;
	look_at(get_global_mouse_position())
	rotation -= deg_to_rad((randf()*inaccuracy) - (inaccuracy / 2))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	position += Vector2(speed, 0).rotated(rotation)
	lifetime += 1;
	if lifetime >= maxLifetime:
		queue_free();
	pass
