extends Camera2D
@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");
@onready var spawnpoint : Node2D = get_node("/root/game/spawnCenter/spawnPoint");

var last : String = "none"
var finishedIntro : bool = false;
var playZoom : bool = false;
var mapSpeed : float = 8.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$dustMap.visible = false;
	$"../spawnRoom/Room_Itself/Borders".modulate.a = 0.0;
	$"../spawnRoom/Room_Itself/backdrop".modulate.a = 0.0;
	$bg.emitting = false;
	position_smoothing_enabled = false;
	position = player.position;
	zoom = Vector2(3.2, 3.2);
	await get_tree().create_timer(0.5).timeout
	position_smoothing_enabled = true;
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if finishedIntro:
		$"../spawnCenter".global_position = global_position;
		if last != gm.nextRoom:
			if gm.nextRoom == "left":
				position.x -= gm.horz;
				gm.roomPos.x -= gm.horz;
				player.position.x -= gm.horz * 0.11;
			elif gm.nextRoom == "right":
				position.x += gm.horz;
				gm.roomPos.x += gm.horz;
				player.position.x += gm.horz * 0.11;
			elif gm.nextRoom == "up":
				position.y -= gm.vert;
				gm.roomPos.y -= gm.vert;
				player.position.y -= gm.vert * 0.2;
			elif gm.nextRoom == "down":
				position.y += gm.vert;
				gm.roomPos.y += gm.vert;
				player.position.y += gm.vert * 0.2;
			last = gm.nextRoom;
			gm.lastRoom = gm.nextRoom;
			gm.nextRoom = "none";
			last = "none";
			
		if player.devCam:
			$dustMap.scale = Vector2(player.camZoom * 2.2, player.camZoom * 2.2);
			$dustMap.visible = true;
			$Dust.visible = false;
			$bg.visible = false;
			position = (gm.lowestCam + gm.highestCam) / 2;
			zoom = lerp(zoom, Vector2(0.5 / player.camZoom, 0.5 / player.camZoom), mapSpeed * delta);
		else:
			$dustMap.visible = false;
			$Dust.visible = true;
			$bg.visible = true;
			zoom = lerp(zoom, Vector2(1, 1), mapSpeed * delta);
			position = gm.roomPos;
			
	if playZoom:
		$bg.emitting = true;
		$"../spawnRoom/Room_Itself/Borders".modulate.a = lerp($"../spawnRoom/Room_Itself/Borders".modulate.a, 1.0, 2 * delta);
		$"../spawnRoom/Room_Itself/backdrop".modulate.a = lerp($"../spawnRoom/Room_Itself/backdrop".modulate.a, 1.0, 2 * delta);
		zoom = lerp(zoom, zoom - Vector2(1, 1), 2 * delta)
		if zoom <= Vector2(1.1, 1.1):
			playZoom = false;
			finishedIntro = true;
			print("finished zoom!")

func _on_in_camera_view_body_exited(body: Node2D) -> void:
	#if body.name == "player":
	#	player.position = position;
	if body.get_parent().is_in_group("playerBullet"):
		body.get_parent().queue_free();
	if body.is_in_group("enemy"):
		body.global_position = spawnpoint.global_position;
	pass


func _on_player_dev_cam_disabled() -> void:
	position = gm.roomPos;
	pass # Replace with function body.


func _on_game_manager_finished_transition_fade() -> void:
	if !gm.isDev:
		await get_tree().create_timer(5).timeout
	position = Vector2(0, 0)
	playZoom = true;
	#for i in 100:
	#	zoom -= Vector2(0.01, 0.01);
	#	await get_tree().create_timer(0.01).timeout;
	#finishedIntro = true;
	pass # Replace with function body.
