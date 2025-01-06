extends StaticBody2D
@onready var gm = get_node("/root/game/gameManager");

var x = 0;
var y = 0;

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
# Called when the node enters the scene tree for the first time
