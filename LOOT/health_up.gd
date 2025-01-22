extends Node2D

@onready var player : Node2D = get_node("/root/game/player");
@onready var gm : Node2D = get_node("/root/game/gameManager");

@onready var status_head: Label = get_node("/root/game/player/status/statusHead");
@onready var status_body: Label = get_node("/root/game/player/status/statusBody");

var collected : bool = false;
var init : bool = false;
var scaleStep : float = 0.01;

var isBought : bool = true;
var price : int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(0, 0);
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
		gm.health += 1;
		gm.updateHealth();
		collected = true;
		print("collected health! ", gm.health)
	pass # Replace with function body.
