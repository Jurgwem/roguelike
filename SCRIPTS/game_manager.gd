extends Node2D
@onready var static_body_2d : StaticBody2D = $"../spawnRoom/Room_Itself"
@onready var player : Node2D = get_node("/root/game/player");

@onready var status_head : Label = $"../player/status/statusHead"
@onready var status_body : Label = $"../player/status/statusBody"

var heartUIRess : Resource = preload("res://INST/heart_ui.tscn");
signal finishedTransitionFade;

var timer : float = 0.0;

var roomType : String = "spawn";
var roomPos : Vector2 = Vector2(0, 0);
var doorDirection : String = "none";
var doorCounter : int = 0;
var hasDoor : bool = false;
var nextRoom : String = "none";
var lastRoom : String = "none";
var horz : int = 1280;
var vert : int = 720;
var isDev : bool = true;
var enemyCount : int = 1;
var randomDoor : int = 0;
var currentAmmo : int = 0;
var maxAmmo : int = 0;
var health : int = 1;
var isDead : bool = false;

var roomCount : int = 1;
var coins : int = 0;
var weapon : String= " ";

var playedFadeIn : bool = false;
var fadeSpeed : float = 0.7;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_body.text = " ";
	status_body.scale.x = 0;
	status_head.text = " ";
	status_head.scale.x = 0;
	$UI.visible = false;
	updateHealth();
	roomPos = static_body_2d.position;
	playedFadeIn = true;
	finishedTransitionFade.emit();
	if !isDev:
		await get_tree().create_timer(5.1).timeout;
	$UI.visible = true;
	await get_tree().create_timer(3).timeout;
	enemyCount -= 1;
	pass # Replace with function body.
	
func die() -> void:
	isDead = true;
	$"../player/status".scale *= 2;
	$"../player/status".position.x += -100;
	status_body.rotation_degrees = -90;
	status_head.position.x += -32;
	status_head.rotation_degrees = -90;
	status_head.text = "You died!";
	status_body.text = str("You got into ", roomCount, " rooms");
	timer = -5;
	await get_tree().create_timer(8).timeout;
	print("quit?");
	pass

func updateHealth() -> void:
	for element : Node2D in get_tree().get_nodes_in_group("heartUI"):
		element.queue_free();
	for i : int in health:
		var heartUI : Node2D = heartUIRess.instantiate();
		heartUI.global_position += Vector2(i * 64, 0);
		$UI/healthPos.add_child(heartUI);
	if health <= 0 and !isDead:
		die();
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if $"../spawnCenter".rotation_degrees >= 360:
		$"../spawnCenter".rotation = 0;
	else:
		$"../spawnCenter".rotation = lerp_angle($"../spawnCenter".rotation, $"../spawnCenter".rotation + 360, 10 * delta);
		
	if playedFadeIn:
		$"../overlay".modulate.a = lerp($"../overlay".modulate.a, $"../overlay".modulate.a - 1, fadeSpeed * delta)
		if $"../overlay".modulate.a <= 0:
			print("finished fade in!");
			playedFadeIn = false;
	
	if status_body.text != " " or status_head.text != " ":
		timer += delta;
		if timer >= 3:
			status_head.scale.x = lerp(status_head.scale.x, 0.0, 10 * delta);
			status_body.scale.x = lerp(status_body.scale.x, 0.0, 10 * delta);
			if status_body.scale.x <= 0.01 or status_head.scale.x <= 0.01:
				print("should reset!")
				status_body.text = " ";
				status_head.text = " "
				status_body.scale.x = 0;
				status_head.scale.x = 0;
				timer = 0;
		else:
			status_head.scale.x = lerp(status_head.scale.x, 1.657, 10 * delta);
			status_body.scale.x = lerp(status_body.scale.x, 1.0, 10 * delta);
	
	
	if $UI.position != roomPos:
		$UI.position = roomPos;
	
	$UI/RoomCounter.text = str("Room: ", roomCount);
	$UI/mod/speedMod.text = str("spd%: ", snapped(player.speedMod, 0.01), "x");
	$UI/mod/damageMod.text = str("dmg%: ", snapped(player.damageMod, 0.01), "x");
	$UI/mod/timeMod.text = str("time%: ", snapped(player.timeMod, 0.01), "x");
	$UI/mod/spreadMod.text = str("srd%: ", snapped(player.spreadMod, 0.01), "x");
	$UI/Coins.text = str(coins, "x");
	$UI/weaponName.text = str(weapon);
	if player.isReloading:
		$UI/ammo.text = "reloading..."
	elif weapon == " ":
		$UI/ammo.text = " ";
	else:
		$UI/ammo.text = str("(", currentAmmo, "/", maxAmmo, ")");
	
	if isDev:
		$UI/dev/FPS.text = str("FPS: ", Engine.get_frames_per_second());
		$UI/dev/roomPos.text = str("roomPos: ", roomPos);
		$UI/dev/enemyCount.text = str("enemies: ", enemyCount);
		$UI/dev/roomType.text = str("roomType: ", roomType);
	else:
		$UI/dev/FPS.visible = false;
		$UI/dev/roomPos.visible = false;
		$UI/dev/enemyCount.visible = false;
		$UI/dev/roomType.visible = false;
	pass
