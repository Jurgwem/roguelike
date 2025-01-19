extends StaticBody2D
@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var spawnpoint : Node2D = get_node("/root/game/spawnCenter/spawnPoint");

#ENEMIES
var batRess : Resource = load("res://ENEMIES/bat.tscn");

#LOOT
var coinRess : Resource = load("res://INST/coin.tscn");
var upgradeRess : Resource = load("res://LOOT/upgrade.tscn");

var chance : float = randf();
var spawnedLoot : bool = false;
var lootChance : float = randf();
var init : bool = false;

var x : int = 0;
var y : int = 0;

func _ready() -> void:
	#print("roomType odds: ", chance);
	if gm.roomCount % 10 == 0:
		gm.roomType = "boss";
	elif chance > 0.9:
		gm.roomType = "gamble";
		$rock.queue_free();
	elif chance > 0.70:
		gm.roomType = "loot";
	else:
		gm.roomType = "enemy";
		
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
	init = true;
	if gm.roomType == "enemy":
		await get_tree().create_timer(randf() * 0.5).timeout;
		print("-=-=- ENEMY COUNTS -=-=-")
		print("BAT: ", floor(gm.roomCount * 0.8), ", ACTUAL: ", gm.roomCount * 0.8);
		print("-=-=- ENEMY COUNTS -=-=-")
		for i in floor(gm.roomCount * 0.6):
			var bat : Node2D= batRess.instantiate();
			add_child(bat);
	await get_tree().create_timer(3).timeout;
	gm.enemyCount -= 1;
	#$CollisionPolygon2D.disabled = false;
	
func _process(delta: float) -> void:
	if init:
		#NORMAL FIGHT ROOM
		if !spawnedLoot and gm.enemyCount == 0 and gm.roomType == "enemy":
			if lootChance > 0.66:
				spawnedLoot = true;
				var coin : Node2D = coinRess.instantiate();
				coin.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(coin);
				print("spawned coin!")
			else:
				spawnedLoot = true;
				var upgrade : Node2D = upgradeRess.instantiate();
				upgrade.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(upgrade);
				print("spawned upgrade!")
		#LOOT ROOM
		if gm.roomType == "loot" and !spawnedLoot:
			if lootChance > 0.66:
				spawnedLoot = true;
				var coin : Node2D = coinRess.instantiate();
				coin.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(coin);
				print("spawned coin!")
			else:
				spawnedLoot = true;
				var upgrade : Node2D = upgradeRess.instantiate();
				upgrade.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(upgrade);
				print("spawned upgrade!")
	pass
