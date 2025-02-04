extends Node2D

@onready var player : Node2D = get_node("/root/game/player");
@onready var gm : Node2D = get_node("/root/game/gameManager");

@onready var status_head: Label = get_node("/root/game/player/status/statusHead");
@onready var status_body: Label = get_node("/root/game/player/status/statusBody");

var chance : float = randf();
var type : int = 0;
var collected : bool = false;
var init : bool = false;
var scaleStep : float = 0.01;

var isBought : bool = true;
var price : int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if isBought and gm.roomType != "loot":
		scale = Vector2(0, 0);
	if chance > 0.72:
		type = 0;
		$Area2D/AnimatedSprite2D.frame = 0;
		#Damage
	elif chance > 0.44:
		type = 1;
		$Area2D/AnimatedSprite2D.frame = 1;
		#Speed
	elif chance > 0.16:
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
		global_position = player.global_position + Vector2(0, -32);
		$parts.emitting = false;
		scale -= Vector2(scaleStep, scaleStep);
		if scale <= Vector2(0, 0):
			queue_free()
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and !collected and !isBought:
		if gm.coins >= price:
			print("bought!")
			gm.coins -= price;
			isBought = true;
		else:
			status_body.text = "not enough coins!";
			status_head.text = " ";
	
	if body.name == "player" and !collected and isBought:
		print("collected upgrade")
		gm.timer = 0;
		if type == 0:
			player.damageMod *= 1.2;
			status_head.text = "Damage!"
			status_body.text = "all damage upgraded"
		elif type == 1:
			player.speedMod *= 1.2;
			status_head.text = "Speed!"
			status_body.text = "movement + bullet speed upgraded"
		elif type == 2:
			player.timeMod *= 0.8;
			status_head.text = "Time!"
			status_body.text = "reload and buffer time reduced"
		elif type == 3:
			player.spreadMod *= 0.8;
			status_head.text = "Spread!"
			status_body.text = "Bullet spread reduced"
		collected = true;
	pass # Replace with function body.
