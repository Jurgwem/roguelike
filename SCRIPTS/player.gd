extends CharacterBody2D
@onready var gm = get_node("/root/game/gameManager");
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = $".."
@onready var camera: Camera2D = $"../camera"

signal shoot;
signal devCamDisabled;
var lastDir = "left";
var slowdown = 0.9;
var maxSpeed = 250;
var accel = 50;
var xvel = 0;
var yvel = 0;
var devCam = false;
var isReloading = false;
var isOnCooldown = false;
var shooting = false;

func _physics_process(delta: float) -> void:
	yvel = yvel * slowdown;
	xvel = xvel * slowdown;
	
	if Input.is_action_just_pressed("dev") and gm.isDev:
		devCam = !devCam;
		if devCam:
			camera.zoom = Vector2(0.5, 0.5);
		else:
			camera.zoom = Vector2(1, 1);
			devCamDisabled.emit();
	
	if Input.is_action_just_pressed("debugOpenDoor") and gm.isDev:
		gm.enemyCount = 0;
		print("Debug set enemy count to 0.");
	
	if Input.is_action_just_pressed("debugCoin") and gm.isDev:
		var coin = load("res://INST/coin.tscn").instantiate();
		add_child(coin);
	
	#NORMAL GAME INPUTS
	if Input.is_action_pressed("right") and (xvel <= maxSpeed):
		animated_sprite_2d.play("walk");
		$walkPart.emitting = true;
		lastDir = "right";
		xvel += accel;
		
	if Input.is_action_pressed("left") and (xvel >= (maxSpeed * -1)):
		animated_sprite_2d.play("walk");
		$walkPart.emitting = true;
		lastDir = "left";
		xvel -= accel;
		
	if Input.is_action_pressed("down") and (yvel <= maxSpeed):
		animated_sprite_2d.play("walk");
		$walkPart.emitting = true;
		yvel += accel;
		
	if Input.is_action_pressed("up") and (yvel >= (maxSpeed * -1)):
		animated_sprite_2d.play("walk");
		$walkPart.emitting = true;
		yvel -= accel;
		
	if Input.is_action_pressed("shoot") and !isOnCooldown and !isReloading and !shooting and gm.weapon != "none":
		shoot.emit();
		shooting = true;
		
	if Input.is_action_just_released("down") or Input.is_action_just_released("up") or Input.is_action_just_released("left") or Input.is_action_just_released("right"):
		animated_sprite_2d.play("idle");
		$walkPart.emitting = false;
		
	velocity.x = xvel;
	velocity.y = yvel;
	
	move_and_slide()
