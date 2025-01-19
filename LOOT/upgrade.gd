extends Node2D

@onready var player : Node2D = get_node("/root/game/player");
@onready var gm : Node2D = get_node("/root/game/gameManager");

var chance : float = randf();
var type : int = 0;
var collected : bool = false;
var init : bool = false;
var scaleStep : float = 0.01;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(0, 0);
	if chance > 0.75:
		type = 0;
		$Area2D/AnimatedSprite2D.frame = 0;
		#Damage
	elif chance > 0.5:
		type = 1;
		$Area2D/AnimatedSprite2D.frame = 1;
		#Speed
	elif chance > 0.25:
		type = 2;
		$Area2D/AnimatedSprite2D.frame = 2;
		#Time
	else:
		type = 3;
		$Area2D/AnimatedSprite2D.frame = 3;
		#Spread
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !init:
		scale += Vector2(scaleStep * 3, scaleStep * 3);
		if scale >= Vector2(1, 1):
			init = true;
		
	if collected and init:
		position = player.position + Vector2(0, -32);
		$parts.emitting = false;
		scale -= Vector2(scaleStep, scaleStep);
		if scale <= Vector2(0, 0):
			queue_free()
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and !collected:
		print("collected upgrade")
		if type == 0:
			player.damageMod *= 1.1;
		elif type == 1:
			player.speedMod *= 1.1;
		elif type == 2:
			player.timeMod *= 0.9;
		elif type == 3:
			player.spreadMod *= 0.8;
		collected = true;
	pass # Replace with function body.
