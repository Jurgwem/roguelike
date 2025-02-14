extends Node2D

@onready var player : Node2D = get_node("/root/game/player");
@onready var gm : Node2D = get_node("/root/game/gameManager");

@onready var status_head: Label = get_node("/root/game/player/status/statusHead");
@onready var status_body: Label = get_node("/root/game/player/status/statusBody");

var pointerRes : Resource = load("res://LOOT/pointer.tscn");

var priceLabel : Label;

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
	if chance > 0.9:
		type = 0;
		$parts.modulate = Color(1, 1, 0);
		$AnimatedSprite2D.frame = 1;
		#Pierce
	elif chance > 0.8:
		type = 1;
		$parts.modulate = Color(1, 0.5, 1);
		$AnimatedSprite2D.frame = 2;
		#Credit Card
	elif chance > 0.7:
		type = 2;
		$parts.modulate = Color(0, 1, 1);
		$AnimatedSprite2D.frame = 3;
		#Ice Cube
	elif chance > 0.6:
		type = 3;
		$parts.modulate = Color(0.5, 0.33, 0);
		$AnimatedSprite2D.frame = 4;
		#Homing
	elif chance > 0.5:
		type = 4;
		$parts.modulate = Color(1, 1, 0);
		$AnimatedSprite2D.frame = 5;
		#More Bullets
	elif chance > 0.4:
		type = 5;
		$AnimatedSprite2D.frame = 6;
		#-1 Room
	elif chance > 0.3:
		type = 6;
		$AnimatedSprite2D.frame = 7;
		#Glue
	elif chance > 0.2:
		type = 7;
		$parts.modulate = Color(0, 1, 0);
		$AnimatedSprite2D.frame = 8;
		#Frog
	elif chance > 0.1:
		type = 8;
		#$parts.modulate = Color(0, 1, 0);
		$AnimatedSprite2D.frame = 9;
		#High Roll
	else:
		type = 9;
		$parts.modulate = Color(1, 0, 0);
		$AnimatedSprite2D.frame = 10
		#Pointer;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if type == 5 and price != 0:
		price = 2;	#adjusted -1 Room price
		priceLabel.text = str(price);
		
	if !init:
		if scale >= Vector2(1, 1):
			init = true;
		else:
			scale += Vector2(scaleStep * 3, scaleStep * 3);
		
	if collected and init:
		global_position = player.global_position + Vector2(0, -32);
		$parts.emitting = false;
		scale -= Vector2(scaleStep, scaleStep);
		if scale <= Vector2(0, 0):
			queue_free()
	pass

func highroll() -> void:
	var tmpHigh : float = player.speedMod;
	if player.damageMod > tmpHigh:
		tmpHigh = player.damageMod;
	var tmpLow : float = player.timeMod;
	if player.spreadMod < tmpLow:
		tmpLow = player.spreadMod;
	player.speedMod = tmpHigh;
	player.damageMod = tmpHigh;
	player.timeMod = tmpLow;
	player.spreadMod = tmpLow;
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
			status_head.text = "Pierce!";
			status_body.text = "bullet piercing increased by 1";
		elif type == 1:
			var moneyYouStoleFromMom : int = int(5 + (randf() * 6));
			gm.coins += moneyYouStoleFromMom;
			status_head.text = "Mom's credit card";
			status_body.text = str(moneyYouStoleFromMom, "? don't tell mom!");
		elif type == 2:
			player.slideMod = 0;
			status_head.text = "Ice Cube";
			status_body.text = "everyone loves ice physics";
		elif type == 3:
			if player.homingMod == 0:
				player.homingMod += 3;
			else:
				player.homingMod *= 1.25;
			status_head.text = "Homing bullets";
			status_body.text = "todo: this is too OP";
			#status_body.text = "more homes = more homing, right?";
		elif type == 4:
			player.ammoMod += 0.25;
			gm.currentAmmo = 0;
			status_head.text = "Extended Ammo";
			status_body.text = "idk man, just more bullets";
		elif type == 5:
			gm.roomCount -= 1;
			status_head.text = "-1 Room";
			status_body.text = "How did you do that?";
		elif type == 6:
			if player.slideMod == 0:
				player.slideMod = 1;
			else:
				player.slideMod += 1;
			status_head.text = "Glue";
			status_body.text = "ew sticky";
		elif type == 7:
			player.maxSpeed = 50;
			player.accel = 1000;
			status_head.text = "Frog!";
			status_body.text = "hop hop hop";
		elif type == 8:
			highroll();
			status_head.text = "High Roll";
			status_body.text = "how lucky!";
		elif type == 9:
			var pointer : Node2D = pointerRes.instantiate();
			pointer.global_position = player.global_position;
			get_node("/root/game/").add_child(pointer);
			status_head.text = "Pointer";
			status_body.text = "definetly useful";
		collected = true;
	pass
