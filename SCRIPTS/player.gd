extends CharacterBody2D
@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node2D = $".."
@onready var camera: Camera2D = $"../camera"

signal shoot;
signal devCamDisabled;
var canMove : bool = false;
var lastDir : String = "left";
var slowdown  :float = 0.9;
var maxSpeed : int = 250;
var accel : int = 50;
var xvel : float = 0;
var yvel : float = 0;
var devCam : bool = false;
var isReloading : bool = false;
var isOnCooldown : bool = false;
var shooting : bool = false;

func _ready() -> void:
	$AnimatedSprite2D.animation = "wakeUp"
	$AnimatedSprite2D.frame = 1;
	pass

func _physics_process(_delta: float) -> void:
	yvel = yvel * slowdown;
	xvel = xvel * slowdown;
	
	if canMove:
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
			var coin : Node2D = load("res://INST/coin.tscn").instantiate();
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
			
		if Input.is_action_pressed("shoot") and gm.currentAmmo >= 1 and !isOnCooldown and !isReloading and !shooting and gm.weapon != "none":
			shoot.emit();
			shooting = true;
			
		if Input.is_action_just_released("down") or Input.is_action_just_released("up") or Input.is_action_just_released("left") or Input.is_action_just_released("right"):
			animated_sprite_2d.play("idle");
			$walkPart.emitting = false;
			
		if Input.is_action_just_pressed("escape"):
			get_tree().change_scene_to_file("res://SCENES/start.tscn")
		
	velocity.x = xvel;
	velocity.y = yvel;
	
	move_and_slide()


func _on_game_manager_finished_transition_fade() -> void:
	if !gm.isDev:
		print("start anim")
		$AnimatedSprite2D.animation = "wakeUp"
		await get_tree().create_timer(2.3).timeout
		$introPart.emitting = true;
		await get_tree().create_timer(2.7).timeout
		print("anim finished")
		$AnimatedSprite2D.animation = "idle"
	canMove = true;
	pass # Replace with function body.
