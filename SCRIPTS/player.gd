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
const KNOCKBACK : float = 16;
var xvel : float = 0;
var yvel : float = 0;
var devCam : bool = false;
var camZoom : float = 1;
var isReloading : bool = false;
var isOnCooldown : bool = false;
var shooting : bool = false;
var hittable : bool = true;

#UPGRADABLE
var speedMod : float = 1;
var damageMod : float = 1;
var timeMod : float = 1;
var spreadMod : float = 1;

#ITEM RELATED
var pierce : int = 0;
var slideMod : float = 1;
var homingMod : float = 0;
var ammoMod : float = 1;

func _ready() -> void:
	
	var chance : float = randf();
	if chance > 0.75:
		speedMod = 1 + ((randf() - 0.5));
		damageMod = 1 + ((randf() - 0.5));
		timeMod = 1 + ((randf() - 0.5) / 2);
		spreadMod = 1 + ((randf() - 0.5) / 2);
		modulate = Color(randf(), randf(), randf());
		scale = Vector2(1.888, 1.5);
	$AnimatedSprite2D.animation = "wakeUp"
	$AnimatedSprite2D.frame = 1;
	pass

func _physics_process(_delta: float) -> void:
	#if get_tree().get_node_count_in_group("enemy") != 0:
	#	look_at(get_tree().get_nodes_in_group("enemy")[0].global_position)
	yvel *= (slowdown ** slideMod);
	xvel *= (slowdown ** slideMod);
	
	if devCam:
		$"../spawnRoom/mapPart".visible = true;
		$"../spawnRoom/mapPart".emitting = true;
		$mapPart.visible = true;
		$mapPart.emitting = true;
		$AnimatedSprite2D.visible = false;
	else:
		$"../spawnRoom/mapPart".visible = false;
		$"../spawnRoom/mapPart".emitting = false;
		$mapPart.visible = false;
		$mapPart.emitting = false;
		$AnimatedSprite2D.visible = true;
	
	
	if modulate != Color(1, 1, 1) and canMove:
		var color : float = lerp(modulate.g, 1.0, 3.2 * _delta);
		modulate = Color(1,color,color);
		if modulate.b > 0.9:
			hittable = true;
			modulate = Color(1, 1, 1)
			print("finished color");
	
	if canMove and !gm.isDead:
		if Input.is_action_just_pressed("map") and gm.enemyCount == 0:
			devCam = !devCam;
			if devCam:
				var tmpX : int = abs(gm.roomPos.x / gm.horz) + 2;
				var tmpY : int = abs(gm.roomPos.y / gm.vert) + 2;
				
				if tmpX > camZoom or tmpY > camZoom:
					if tmpX >= tmpY:
						camZoom = tmpX;
					else:
						camZoom = tmpY;
				print("zoom: ", camZoom);
				print("map Pos: ", (gm.lowestCam + gm.highestCam) / 2);
				#if zoom != 0:
				#camera.zoom = Vector2(0.5 / zoom, 0.5 / zoom)
				#else:
					#camera.zoom = Vector2(1, 1);
			#else:
			#	camera.zoom = Vector2(1, 1);
				devCamDisabled.emit();
		
		#DEBUG
		if gm.isDev:
			if Input.is_action_just_pressed("debugCoin"):
				var coin : Node2D = load("res://LOOT/coin.tscn").instantiate();
				coin.position = get_global_mouse_position();
				$"..".add_child(coin);
				
			if Input.is_action_just_pressed("debugUpgrade"):
				var upgrade : Node2D = load("res://LOOT/upgrade.tscn").instantiate();
				upgrade.position = get_global_mouse_position();
				$"..".add_child(upgrade);
			
			if Input.is_action_just_pressed("debugHealth"):
				var health : Node2D = load("res://LOOT/health_up.tscn").instantiate();
				health.position = get_global_mouse_position();
				$"..".add_child(health);
				
			if Input.is_action_just_pressed("debugItem"):
				var item : Node2D = load("res://LOOT/basic_item.tscn").instantiate();
				item.position = get_global_mouse_position();
				$"..".add_child(item);
			
			if Input.is_action_just_pressed("debugBat"):
				var bat : Node2D = load("res://ENEMIES/bat.tscn").instantiate();
				bat.position = get_global_mouse_position();
				$"..".add_child(bat);
			
			if Input.is_action_just_pressed("debugInvMan"):
				var man : Node2D = load("res://ENEMIES/inv_man.tscn").instantiate();
				man.position = get_global_mouse_position();
				$"..".add_child(man);
				
			if Input.is_action_just_pressed("debugFroggit"):
				var froggit : Node2D = load("res://ENEMIES/froggit.tscn").instantiate();
				froggit.position = get_global_mouse_position();
				$"..".add_child(froggit);
			
			if Input.is_action_just_pressed("debugHurt"):
				gm.health -= 1;
				gm.updateHealth(gm.name);
		
		#NORMAL GAME INPUTS

		if Input.is_action_pressed("right") and (xvel <= maxSpeed * speedMod):
			animated_sprite_2d.play("walk");
			$walkPart.emitting = true;
			lastDir = "right";
			xvel += accel * speedMod;
			
		if Input.is_action_pressed("left") and (xvel >= (maxSpeed * -1 * speedMod)):
			animated_sprite_2d.play("walk");
			$walkPart.emitting = true;
			lastDir = "left";
			xvel -= accel * speedMod;
			
		if Input.is_action_pressed("down") and (yvel <= maxSpeed * speedMod):
			animated_sprite_2d.play("walk");
			$walkPart.emitting = true;
			yvel += accel * speedMod;
			
		if Input.is_action_pressed("up") and (yvel >= (maxSpeed * -1 * speedMod)):
			animated_sprite_2d.play("walk");
			$walkPart.emitting = true;
			yvel -= accel * speedMod;
			
		if Input.is_action_pressed("shoot") and gm.currentAmmo >= 1 and !isOnCooldown and !isReloading and !shooting and gm.weapon != "none":
			shoot.emit();
			shooting = true;
			
		if Input.is_action_just_released("down") or Input.is_action_just_released("up") or Input.is_action_just_released("left") or Input.is_action_just_released("right"):
			animated_sprite_2d.play("idle");
			$walkPart.emitting = false;
			
	if !gm.isDead:
		velocity.x = xvel;
		velocity.y = yvel;
		move_and_slide()
	else:
		$AnimatedSprite2D.animation = "wakeUp";
		$AnimatedSprite2D.frame = 5;
		$walkPart.emitting = false;
		if rotation_degrees != 90:
			rotation = lerp_angle(rotation, deg_to_rad(90), 10 * _delta);


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
	scale = Vector2(1.888, 1.888);
	pass # Replace with function body.


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.health >= 1:
			if !gm.isDead and hittable:
				modulate = Color(1,0.25,0.25);
			var distance_vector_player : Vector2 = global_position - body.global_position;
			xvel = distance_vector_player.x * KNOCKBACK;
			yvel = distance_vector_player.y * KNOCKBACK;
			body.velocity = distance_vector_player * -1 * (KNOCKBACK/2);
			if hittable:
				hittable = false;
				gm.health -= 1;
				gm.updateHealth(body.endName);
			#velocity = distance_vector.normalized() * (knockback * 100);
			#move_and_slide()
	pass # Replace with function body.
