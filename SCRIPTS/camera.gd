extends Camera2D
@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");

var last : String = "none"
var finishedIntro : bool = false;
var playZoom : bool = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$bg.emitting = false;
	position_smoothing_enabled = false;
	position = player.position;
	zoom = Vector2(2, 2);
	await get_tree().create_timer(0.1).timeout
	position_smoothing_enabled = true;
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if finishedIntro:
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
				player.position.y -= gm.vert * 0.14;
			elif gm.nextRoom == "down":
				position.y += gm.vert;
				gm.roomPos.y += gm.vert;
				player.position.y += gm.vert * 0.14;
			last = gm.nextRoom;
			gm.lastRoom = gm.nextRoom;
			gm.nextRoom = "none";
			$"../spawnCenter".position = position;
			last = "none";
		if player.devCam:
			position = player.position;
	if playZoom:
		$bg.emitting = true;
		zoom = lerp(zoom, zoom - Vector2(1, 1), 1 * delta)
		if zoom <= Vector2(1, 1):
			playZoom = false;
			finishedIntro = true;
			print("finished zoom!")

func _on_in_camera_view_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player.position = position;
	if body.get_parent().is_in_group("playerBullet"):
		body.get_parent().queue_free();
	if body.is_in_group("enemy"):
		body.position = position;
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
