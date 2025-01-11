extends Node2D
@onready var start_player: Node2D = $"../startPlayer"
var bulletRess : Resource= preload("res://PROJECTILES/default_bullet.tscn");

var shoot : bool = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	position = start_player.position;
	look_at(get_global_mouse_position())
	if rotation_degrees < -90:
		rotation += deg_to_rad(360);
	elif rotation_degrees > 270:
		rotation -= deg_to_rad(360);
	if rotation_degrees >= 90 and rotation_degrees <= 270:
		$shootPart.position.y = 3;
		$shell.scale = Vector2(1, -1)
		$shell.position = Vector2(16, 3);
		$Sprite2D.flip_v = true;
	else:
		$shootPart.position.y = 0;
		$shell.scale = Vector2(1, 1);
		$shell.position = Vector2(16, -2);
		$Sprite2D.flip_v = false;
	if Input.is_action_just_pressed("shoot") and shoot:
		var bullet : Node = bulletRess.instantiate();
		$"..".add_child(bullet);
	pass
