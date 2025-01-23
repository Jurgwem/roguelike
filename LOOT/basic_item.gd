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
	scale = Vector2(0, 0);
	if chance > 0.75:
		type = 0;
		$parts.modulate = Color(1, 1, 0);
		$AnimatedSprite2D.frame = 0;
		#Pierce
	elif chance > 0.50:
		type = 1;
		$parts.modulate = Color(1, 0.5, 1);
		$AnimatedSprite2D.frame = 1;
		#Credit Card
	elif chance > 0.25:
		type = 2;
		$parts.modulate = Color(0, 1, 1);
		$AnimatedSprite2D.frame = 2;
		#Ice Cube
	else:
		type = 3;
		$parts.modulate = Color(0.5, 0.33, 0);
		$AnimatedSprite2D.frame = 3;
		#Homing

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
			player.pierce += 1;
			status_head.text = "Pierce!"
			status_body.text = "bullet piercing increased by 1"
		elif type == 1:
			gm.coins += int(6 + (randf() * 6));
			status_head.text = "Mom's credit card"
			status_body.text = "don't tell mom!"
		elif type == 2:
			player.slideMod = 0;
			status_head.text = "Ice Cube"
			status_body.text = "everyone loves ice physics"
		elif type == 3:
			player.homingMod += 4;
			status_head.text = "Homing bullets"
			status_body.text = "more homes = more homing, right?"
		collected = true;
	pass # Replace with function body.
