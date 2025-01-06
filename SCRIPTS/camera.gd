extends Camera2D
@onready var gm = get_node("/root/game/gameManager");
@onready var player = get_node("/root/game/player");

var last = "none"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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
		last = "none";
	if player.devCam:
		position = player.position;
	pass

func _on_in_camera_view_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player.position = position;
		pass


func _on_player_dev_cam_disabled() -> void:
	position = gm.roomPos;
	pass # Replace with function body.
