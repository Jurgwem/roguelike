extends Node2D

@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");

var bulletRess : Resource= load("res://PROJECTILES/default_bullet.tscn");

var equipped : bool = false;
var init : bool = false;
var startPos : Vector2 = position;

var reloadTime : int = 2;
var shootBuffer : float = 0.33;
var ammo : int = 12;
var rotSpeed : int = 8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var bullet : Node = bulletRess.instantiate();
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
			gm.weapon = "Gun";
			gm.maxAmmo = ammo;
			gm.currentAmmo = 0;
			$GPUParticles2D.emitting = false;
			scale = Vector2(1.5, 1.5)
		position = player.position;
		
		if (!player.isReloading):
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
			gm.currentAmmo = ammo;
			print("reloaded!");
			
		if player.shooting and !player.isOnCooldown and !player.isReloading:
			player.isOnCooldown = true;
			player.shooting = false;
			$"..".add_child(bullet);
			$shell.emitting =  true;
			$shell.restart();
			$shootPart.emitting = true;
			gm.currentAmmo -= 1;
			await get_tree().create_timer(shootBuffer * player.timeMod).timeout
			player.isOnCooldown = false;
			
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player" and gm.weapon == " ":
		equipped = true;
	pass # Replace with function body.
