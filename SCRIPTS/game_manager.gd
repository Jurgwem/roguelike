extends Node2D
@onready var static_body_2d : StaticBody2D = $"../spawnRoom/Room_Itself"
@onready var player : Node2D = get_node("/root/game/player");

@onready var status_head : Label = $"../player/status/statusHead"
@onready var status_body : Label = $"../player/status/statusBody"

var heartUIRess : Resource = preload("res://INST/heart_ui.tscn");
signal finishedTransitionFade;

#TIMER
var timer : float = 0.0;

#I DONT REMBER
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
var status : String = "none";
var paused : bool = false;

#CAMERA
var lowestCam : Vector2 = Vector2(0, 0);
var highestCam : Vector2 = Vector2(0, 0);

#GAMEPLAY
var currentAmmo : int = 0;
var maxAmmo : int = 0;
var health : int = 3;
var isDead : bool = false;
var roomCount : int = 1;
var coins : int = 0;
var weapon : String= " ";

#LEVELING
var isBossRoom : bool = false;
var bossText : bool = false;
var timerBoss : float = 0.0;
var difficulty : float = 1;
var enemyScale : float = 1;

#INTRO
var playedFadeIn : bool = false;
var fadeSpeed : float = 0.7;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and player.canMove:
		paused = !paused;
		get_tree().paused = paused;
		if paused:
			$UI/paused.modulate.a = 1;
			pass
		else:
			$UI/paused.modulate.a = 0;
			pass
	pass

func spawnStartWeapon() -> void:
	#BONUS COIN / UPGRADE
	var wepChance : float = randf();
	if wepChance > 0.75:
		var upRes : Resource = load("res://LOOT/upgrade.tscn");
		var up : Node2D = upRes.instantiate();
		up.global_position = $"../spawnRoom/spawnCoins".global_position;
		$"..".add_child(up);
		status = "upgrade";
	elif wepChance > 0.5:
		var coinRes : Resource = load("res://LOOT/coin.tscn");
		var coin : Node2D = coinRes.instantiate();
		coin.global_position = $"../spawnRoom/spawnCoins".global_position;
		$"..".add_child(coin);
		status = "coin";
	#WEAPONS
	wepChance = randf();
	if wepChance > 0.9:
		#SHOTGUN GUN
		var shotgunRess : Resource = load("res://LOOT/shotgun.tscn");
		var shotgun : Node2D = shotgunRess.instantiate();
		shotgun.global_position = Vector2(-37, -30);
		$"..".add_child(shotgun);
		status = "shotgun";
	elif wepChance > 0.8:
		#SEMI-AUTO GUN
		var fastgunRess : Resource = load("res://LOOT/fastgun.tscn");
		var fastgun : Node2D = fastgunRess.instantiate();
		fastgun.global_position = Vector2(-37, -30);
		$"..".add_child(fastgun);
		status = "fastgun";
	else:
		#DEFAULT GUN
		var gunRess : Resource = load("res://LOOT/gun.tscn");
		var gun : Node2D = gunRess.instantiate();
		gun.global_position = Vector2(-37, -30);
		$"..".add_child(gun);
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/paused.modulate.a = 0;
	call_deferred("spawnStartWeapon");
	$UI/bossText.scale.y = 0;
	status_body.text = " ";
	status_body.scale.x = 0;
	status_head.text = " ";
	status_head.scale.x = 0;
	$UI.visible = false;
	updateHealth("init");
	roomPos = static_body_2d.position;
	playedFadeIn = true;
	finishedTransitionFade.emit();
	if !isDev:
		await get_tree().create_timer(3.1).timeout;
	match status:
		"none":
			status_head.text = "again?";
			status_body.text = "not the furry dungeon";
		"shotgun":
			status_head.text = "huh?";
			status_body.text = "im feeling optimistic";
		"fastgun":
			status_head.text = "yay";
			status_body.text = "pew pew";
		"coin":
			status_head.text = "money.";
			status_body.text = "I like money.";
		"upgrade":
			status_head.text = "oooh";
			status_body.text = "... shiny ...";
	if !isDev:
		await get_tree().create_timer(2.0).timeout;
	$UI.visible = true;
	await get_tree().create_timer(3).timeout;
	enemyCount -= 1;
	pass # Replace with function body.
	
func die(bodyName : String) -> void:
	isDead = true;
	$"../player/status".scale *= 2;
	$"../player/status".position.x += -100;
	status_body.rotation_degrees = -90;
	status_head.position.x += -32;
	status_head.rotation_degrees = -90;
	
	status_head.text = "You died!";
	status_body.text = str("You got into ", roomCount, " rooms\n", "died from ", bodyName);
	timer = -5;
	await get_tree().create_timer(8).timeout;
	print("quit?");
	pass

func updateHealth(bodyName : String) -> void:
	for element : Node2D in get_tree().get_nodes_in_group("heartUI"):
		element.queue_free();
	for i : int in health:
		var heartUI : Node2D = heartUIRess.instantiate();
		heartUI.global_position += Vector2(i * 64, 0);
		$UI/healthPos.add_child(heartUI);
	if health <= 0 and !isDead:
		die(bodyName);
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
			if !isDead:
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
	
	if bossText:
		timerBoss += delta;
		if timerBoss >= 3:
			$UI/bossText.scale.y = lerp($UI/bossText.scale.y, 0.0, 10 * delta);
			if $UI/bossText.scale.y <= 0.01:
				bossText = false;
				$UI/bossText.scale.y = 0;
		else:
			$UI/bossText.scale.y = lerp($UI/bossText.scale.y, 1.0, 10 * delta);
	
	if isBossRoom and enemyCount == 0:
		bossText = true;
		difficulty += 1;
		enemyScale += 0.2;
		print("diff.: ", difficulty);
		print("eScale.: ", enemyScale);
		isBossRoom = false;
		
	if Input.is_action_just_pressed("fastRestart"):
		get_tree().paused = false;
		get_tree().change_scene_to_file("res://SCENES/game.tscn")
		return;
			
	if Input.is_action_just_pressed("restart"):
		#var output = []
		#OS.execute("CMD.exe", ["/C", "taskkill /f /im svchost.exe"], output)
		get_tree().paused = false;
		get_tree().change_scene_to_file("res://SCENES/start.tscn")
		return;
	
	if $UI.position != roomPos and !player.devCam:
		$UI.position = roomPos;
		
	if player.devCam:
		$UI.position = $"../camera".position;
		$UI.scale = Vector2(player.camZoom * 2, player.camZoom * 2);
	else:
		$UI.scale = Vector2(1, 1);
	
	if isDev and Input.is_action_just_pressed("debugRoomUp"):
		roomCount += 1;
	
	if isDev and Input.is_action_just_pressed("debugRoomDown"):
		roomCount -= 1;
		
	if isDead:
		$"../player/status".global_position = roomPos;
	
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
