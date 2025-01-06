extends Node2D
@onready var static_body_2d: StaticBody2D = $"../spawnRoom/Room_Itself"

var roomPos = Vector2(0, 0);
var doorDirection = "none";
var doorCounter = 0;
var hasDoor = false;
var nextRoom = "none";
var lastRoom = "none";
var horz = 1280;
var vert = 720;
var isDev = true;
var enemyCount = 1;
var randomDoor = 0;
var currentAmmo = 0;
var maxAmmo = 0;

var roomCount = 1;
var coins = 0;
var weapon = "none";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roomPos = static_body_2d.position;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$UI.position = roomPos;
	$UI/RoomCounter.text = str("Room: ", roomCount);
	$UI/Coins.text = str(coins, "x");
	$UI/weaponName.text = str(weapon);
	$UI/ammo.text = str("(", currentAmmo, "/", maxAmmo, ")");
	
	if isDev:
		$UI/FPS.text = str("FPS: ", Engine.get_frames_per_second());
		$UI/roomPos.text = str("roomPos: ", roomPos);
	else:
		$UI/FPS.queue_free();
		$UI/roomPos.queue_free();
	pass
