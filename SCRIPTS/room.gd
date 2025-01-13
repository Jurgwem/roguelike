extends StaticBody2D
@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var spawnpoint : Node2D = get_node("/root/game/spawnCenter/spawnPoint");

var batRess : Resource= load("res://ENEMIES/bat.tscn");

var x : int = 0;
var y : int = 0;

func _ready() -> void:
	gm.hasDoor = false;
	gm.randomDoor = 0;
	if gm.nextRoom == "left" or gm.nextRoom == "right":
		y = gm.roomPos.y;
		if gm.nextRoom == "right":
			x = gm.roomPos.x + gm.horz;
		else:
			x = gm.roomPos.x - gm.horz;
	else:
		x = gm.roomPos.x;
		if gm.nextRoom == "down":
			y = gm.roomPos.y + gm.vert;
		else:
			y = gm.roomPos.y - gm.vert;
	position = Vector2(x, y);
	await get_tree().create_timer(randf() * 0.5).timeout;
	print("-=-=- ENEMY COUNTS -=-=-")
	print("BAT: ", floor(gm.roomCount * 0.8), ", ACTUAL: ", gm.roomCount * 0.8);
	print("-=-=- ENEMY COUNTS -=-=-")
	for i in floor(gm.roomCount * 0.8):
		var bat = batRess.instantiate();
		add_child(bat);
	await get_tree().create_timer(3).timeout;
	gm.enemyCount -= 1;
	#$CollisionPolygon2D.disabled = false;
# Called when the node enters the scene tree for the first time
