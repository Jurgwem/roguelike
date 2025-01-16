extends Node2D
@onready var static_body_2d: StaticBody2D = $"../spawnRoom/Room_Itself"
@onready var player : Node2D = get_node("/root/game/player");

signal finishedTransitionFade;

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

var roomCount : int = 1;
var coins : int = 0;
var weapon : String= " ";

var playedFadeIn : bool = false;
var fadeSpeed : float = 0.7;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI.visible = false;
	roomPos = static_body_2d.position;
	playedFadeIn = true;
	finishedTransitionFade.emit();
	if !isDev:
		await get_tree().create_timer(5.1).timeout;
	$UI.visible = true;
	await get_tree().create_timer(3).timeout;
	enemyCount -= 1;
	pass # Replace with function body.

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
	$UI.position = roomPos;
	$UI/RoomCounter.text = str("Room: ", roomCount);
	$UI/Coins.text = str(coins, "x");
	$UI/weaponName.text = str(weapon);
	if player.isReloading:
		$UI/ammo.text = "reloading..."
	elif weapon == " ":
		$UI/ammo.text = " ";
	else:
		$UI/ammo.text = str("(", currentAmmo, "/", maxAmmo, ")");
	
	if isDev:
		$UI/FPS.text = str("FPS: ", Engine.get_frames_per_second());
		$UI/roomPos.text = str("roomPos: ", roomPos);
		$UI/enemyCount.text = str("enemies: ", enemyCount);
	else:
		$UI/FPS.visible = false;
		$UI/roomPos.visible = false;
		$UI/enemyCount.visible = false;
	pass
