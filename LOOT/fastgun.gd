extends Node2D

@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");

@onready var status_head: Label = get_node("/root/game/player/status/statusHead");
@onready var status_body: Label = get_node("/root/game/player/status/statusBody");

var bulletRess : Resource= load("res://PROJECTILES/default_bullet.tscn");

var equipped : bool = false;
var init : bool = false;
var startPos : Vector2 = position;

var reloadTime : int = 3;
var shootBuffer : float = 0.1;
var ammo : int = 12;
var rotSpeed : int = 8

var isBought : bool = true;
var price : int = 0;

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if equipped and Input.is_action_just_pressed("unequip"):
		rotation = deg_to_rad(0);
		gm.weapon = " ";
		gm.maxAmmo = 0;
		gm.currentAmmo = 0;
		player.isReloading = false;
		$Sprite2D.flip_v = false;
		scale = Vector2(2, 2)
		$GPUParticles2D.emitting = true;
		equipped = false;
		init = false;
	if equipped:
		if !init:
			init = true;
			gm.weapon = "Semi-Auto";
			gm.maxAmmo = ammo * player.ammoMod;
			gm.currentAmmo = 0;
			$GPUParticles2D.emitting = false;
			scale = Vector2(1.75, 1.75)
		global_position = player.global_position;
		
		if (!player.isReloading):
			if !gm.isDead:
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
		else:
			if !$Sprite2D.flip_v:
				var rotation_diff : float = deg_to_rad(45) - rotation 
				rotation_diff = clamp(rotation_diff, -rotSpeed * delta, rotSpeed * delta)
				rotation += rotation_diff
				#rotation = deg_to_rad(45);
			else:
				var rotation_diff : float = deg_to_rad(135) - rotation 
				rotation_diff = clamp(rotation_diff, -rotSpeed * delta, rotSpeed * delta)
				rotation += rotation_diff
				#rotation = deg_to_rad(135);
		
		if (gm.currentAmmo <= 0 or Input.is_action_just_pressed("reload")) and !player.isReloading:
			player.isReloading = true;
			print("no ammo, reloading...");
			await get_tree().create_timer(reloadTime * player.timeMod).timeout;
			player.isReloading = false;
			gm.currentAmmo = ammo * player.ammoMod;
			gm.maxAmmo = ammo * player.ammoMod;
			print("reloaded!");
			
		if player.shooting and !player.isOnCooldown and !player.isReloading:
			var bullet : Node = bulletRess.instantiate();
			player.isOnCooldown = true;
			player.shooting = false;
			bullet.inaccuracy = 16;
			bullet.damage = 6;
			$"..".add_child(bullet);
			$shell.emitting =  true;
			$shell.restart();
			$shootPart.emitting = true;
			gm.currentAmmo -= 1;
			await get_tree().create_timer(shootBuffer * player.timeMod).timeout
			player.isOnCooldown = false;
			
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and !isBought:
		if gm.coins >= price:
			print("bought!")
			gm.coins -= price;
			isBought = true;
		else:
			status_body.text = "not enough coins!";
			status_head.text = " ";
	
	if body.name == "player" and gm.weapon == " " and isBought:
		equipped = true;
	pass # Replace with function body.
