extends StaticBody2D
@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var spawnpoint : Node2D = get_node("/root/game/spawnCenter/spawnPoint");

#ENEMIES
var batRess : Resource = load("res://ENEMIES/bat.tscn");

#LOOT
var coinRess : Resource = load("res://LOOT/coin.tscn");
var heartRess : Resource = load("res://LOOT/health_up.tscn");
var upgradeRess : Resource = load("res://LOOT/upgrade.tscn");

const UPGRADE_PRICE : int = 3;
const HEALTH_PRICE : int = 4;

var chance : float = randf();
var spawnedLoot : bool = false;
var lootChance : float = randf();
var init : bool = false;
var shopChance : float = 0.0;

var x : int = 0;
var y : int = 0;

func spawnShopHeart(pos: Vector2) -> void:
	var heart : Node2D = heartRess.instantiate();
	heart.position += pos;
	heart.isBought = false;
	heart.price = HEALTH_PRICE;
	add_child(heart);
	pass
	
func spawnShopUpgrade(pos: Vector2) -> void:
	var upgrade : Node2D = upgradeRess.instantiate();
	upgrade.position += pos;
	upgrade.isBought = false;
	upgrade.price = UPGRADE_PRICE;
	add_child(upgrade);
	pass

func shopInit() -> void:
	print("shop init")
	
	#LEFT SLOT
	shopChance = randf();
	if shopChance > 0.66:
		spawnShopHeart(Vector2(-127, -32));
		$SHOP/pLeft.text = str(HEALTH_PRICE);
	else:
		spawnShopUpgrade(Vector2(-127, -32));
		$SHOP/pLeft.text = str(UPGRADE_PRICE);
	
	#MIDDLE SLOT
	shopChance = randf();
	if shopChance > 0.66:
		spawnShopHeart(Vector2(1, -32));
		$SHOP/pMiddle.text = str(HEALTH_PRICE);
	else:
		spawnShopUpgrade(Vector2(1, -32));
		$SHOP/pMiddle.text = str(UPGRADE_PRICE);
	
	#RIGHT SLOT
	pass;

func _ready() -> void:
	#print("roomType odds: ", chance);
	if gm.roomCount % 10 == 0:
		gm.roomType = "boss";
		$rock.queue_free();
		$GAMBLE.queue_free();
		$SHOP.queue_free();
	elif chance > 0.95:
		gm.roomType = "gamble";
		spawnedLoot = true;
		$rock.queue_free();
		$SHOP.queue_free();
	elif chance > 0.80:
		gm.roomType = "shop";
		spawnedLoot = true;
		$GAMBLE.queue_free();
		shopInit();
	elif chance > 0.65:
		gm.roomType = "loot";
		$GAMBLE.queue_free();
		$SHOP.queue_free();
	else:
		gm.roomType = "enemy";
		$GAMBLE.queue_free();
		$SHOP.queue_free();
		
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
		for i : int in floor(gm.roomCount * 0.6):
			var bat : Node2D= batRess.instantiate();
			add_child(bat);
	await get_tree().create_timer(3).timeout;
	gm.enemyCount -= 1;
	#$CollisionPolygon2D.disabled = false;
	
func _physics_process(_delta: float) -> void:
	if init:
		#NORMAL FIGHT ROOM
		if !spawnedLoot and gm.enemyCount == 0 and gm.roomType == "enemy":
			if lootChance > 0.66:
				spawnedLoot = true;
				var coin : Node2D = coinRess.instantiate();
				coin.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(coin);
				print("spawned coin! (enemy)")
			else:
				spawnedLoot = true;
				var upgrade : Node2D = upgradeRess.instantiate();
				upgrade.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(upgrade);
				print("spawned upgrade! (enemy)")
		#LOOT ROOM
		if !spawnedLoot and gm.roomType == "loot":
			if lootChance > 0.66:
				spawnedLoot = true;
				var coin : Node2D = coinRess.instantiate();
				coin.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(coin);
				print("spawned coin! (loot)")
			else:
				spawnedLoot = true;
				var upgrade : Node2D = upgradeRess.instantiate();
				upgrade.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(upgrade);
				print("spawned upgrade! (loot)")
		if !spawnedLoot and gm.roomType == "boss":
			spawnedLoot = true;
	pass
