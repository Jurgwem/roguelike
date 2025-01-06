extends Node2D

@onready var gm = get_node("/root/game/gameManager");
@onready var player = get_node("/root/game/player");

var equipped = false;
var init = false;
var startPos = position;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if equipped and Input.is_action_just_pressed("unequip"):
		rotation = deg_to_rad(0);
		gm.weapon = "none";
		$Sprite2D.flip_v = false;
		scale = Vector2(2, 2)
		$GPUParticles2D.emitting = true;
		equipped = false;
		init = false;
	if equipped:
		if !init:
			init = true;
			gm.weapon = "Gun";
			$GPUParticles2D.emitting = false;
			scale = Vector2(1.5, 1.5)
		position = player.position;
		look_at(get_global_mouse_position())
		if rotation_degrees < -90:
			rotation += deg_to_rad(360);
		elif rotation_degrees > 270:
			rotation -= deg_to_rad(360);
		if rotation_degrees >= 90 and rotation_degrees <= 270:
			$Sprite2D.flip_v = true;
		else:
			$Sprite2D.flip_v = false;
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		equipped = true;
	pass # Replace with function body.
