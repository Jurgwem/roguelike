extends StaticBody2D
@onready var gm : Node2D = get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");
@onready var spawnpoint : Node2D = get_node("/root/game/spawnCenter/spawnPoint");

#ENEMIES
var batRess : Resource = load("res://ENEMIES/bat.tscn");
var invRess : Resource = load("res://ENEMIES/inv_man.tscn");
var froggitRess : Resource = load("res://ENEMIES/froggit.tscn");

#LOOT
var coinRess : Resource = load("res://LOOT/coin.tscn");
var heartRess : Resource = load("res://LOOT/health_up.tscn");
var upgradeRess : Resource = load("res://LOOT/upgrade.tscn");
var itemRess : Resource = load("res://LOOT/basic_item.tscn");

const UPGRADE_PRICE : int = 2;
const HEALTH_PRICE : int = 4;
const ITEM_PRICE : int = 5;

var chance : float = randf();
var selfType : String = " ";
var spawnedLoot : bool = false;
var lootChance : float = randf();
var init : bool = false;
var shopChance : float = 0.0;
var bossChance : float = randf();

var x : int = 0;
var y : int = 0;

func spawnShopHeart(pos: Vector2) -> void:
	var heart : Node2D = heartRess.instantiate();
	heart.position += pos;
	heart.isBought = false;
	heart.price = HEALTH_PRICE;
	add_child(heart);
	pass
	
func spawnShopUpgrade(pos: Vector2, label: Label) -> void:
	var upgrade : Node2D = upgradeRess.instantiate();
	upgrade.position += pos;
	upgrade.isBought = false;
	upgrade.price = UPGRADE_PRICE;
	add_child(upgrade);
	label.text = str(UPGRADE_PRICE);
	pass

func spawnShopItem(pos: Vector2, label: Label) -> void:
	var item : Node2D = itemRess.instantiate();
	item.position += pos;
	item.isBought = false;
	item.price = ITEM_PRICE;
	item.priceLabel = label;
	label.text = str(ITEM_PRICE);
	add_child(item);
	pass
	
func spawnWeaponShop(pos: Vector2, label: Label) -> void:
	shopChance = randf();
	if shopChance > 0.66:
		#DEFAULT GUN
		var gunPrice : int = 4;
		var gunRess : Resource = load("res://LOOT/gun.tscn");
		var gun : Node2D = gunRess.instantiate();
		gun.isBought = false;
		gun.price = gunPrice;
		gun.global_position = pos - Vector2(38, 0);
		add_child(gun);
		label.text = str(gunPrice);
	elif shopChance > 0.33:
		#SEMI-AUTO GUN
		var fastgunPrice : int = 6;
		var fastgunRess : Resource = load("res://LOOT/fastgun.tscn");
		var fastgun : Node2D = fastgunRess.instantiate();
		fastgun.isBought = false;
		fastgun.price = fastgunPrice;
		fastgun.global_position = pos - Vector2(38, -4);
		add_child(fastgun);
		label.text = str(fastgunPrice);
	else:
		#SHOTGUN GUN
		var shotgunPrice : int = 8;
		var shotgunRess : Resource = load("res://LOOT/shotgun.tscn");
		var shotgun : Node2D = shotgunRess.instantiate();
		shotgun.isBought = false;
		shotgun.price = shotgunPrice;
		shotgun.global_position = pos - Vector2(38, 0);
		add_child(shotgun);
		label.text = str(shotgunPrice);
	pass

func shopInit() -> void:
	print("shop init")
	
	#LEFT SLOT
	shopChance = randf();
	if shopChance > 0.66:
		spawnShopHeart(Vector2(-127, -34));
		$SHOP/pLeft.text = str(HEALTH_PRICE);
	else:
		spawnShopUpgrade(Vector2(-127, -34), $SHOP/pLeft);
		#$SHOP/pLeft.text = str(UPGRADE_PRICE);
	
	#MIDDLE SLOT
	shopChance = randf();
	if shopChance > 0.66:
		spawnShopHeart(Vector2(1, -34));
		$SHOP/pMiddle.text = str(HEALTH_PRICE);
	elif shopChance > 0.33:
		spawnShopUpgrade(Vector2(1, -34), $SHOP/pMiddle);
	else:
		spawnShopItem(Vector2(1, -34), $SHOP/pMiddle);
	
	#RIGHT SLOT
	shopChance = randf();
	if shopChance > 0.66:
		spawnShopItem(Vector2(129, -34), $SHOP/pRight);
	else:
		spawnWeaponShop(Vector2(129, -34), $SHOP/pRight);
	pass;

func _ready() -> void:
	player.devCam = false;
	#print("roomType odds: ", chance);
	if gm.roomCount % 10 == 0:
		gm.roomType = "boss";
		selfType = "boss";
		gm.isBossRoom = true;
		$rock.queue_free();
		$GAMBLE.queue_free();
		$SHOP.queue_free();
	elif chance > 0.95:
		gm.roomType = "gamble";
		selfType = "gamble";
		spawnedLoot = true;
		$rock.queue_free();
		$SHOP.queue_free();
	elif chance > 0.80:
		gm.roomType = "shop";
		selfType = "shop";
		spawnedLoot = true;
		$GAMBLE.queue_free();
		shopInit();
	elif chance > 0.65:
		gm.roomType = "loot";
		selfType = "loot";
		$GAMBLE.queue_free();
		$SHOP.queue_free();
	else:
		gm.roomType = "enemy";
		selfType = "enemy";
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
	print("gm: ", gm.roomPos);
	#print("own Pos: ", Vector2(x, y));
	#global_position = Vector2(x, y);
	global_position = gm.roomPos;
	if global_position > gm.highestCam:
		gm.highestCam = global_position;
	if global_position < gm.lowestCam:
		gm.lowestCam = global_position;
	print("Highest: ", gm.highestCam);
	print("Lowest: ", gm.lowestCam);
	init = true;
	
	#BAT SPAWN COUNT
	var batCount : int = 0;
	if gm.roomCount < 10:
		batCount = floor(gm.roomCount * 0.6);
	else:
		batCount = 6;
	if gm.roomCount > 10 and gm.roomCount < 18:
		batCount = 4;
	
	#INV MAN SPAWN COUNT
	var invCount : int = 0;
	if gm.roomCount >= 7:
		if gm.roomCount >= 25:
			invCount = 5;
		else:
			invCount = floor(gm.roomCount * 0.2);
		#if gm.roomCount <= 22:
			#invCount = 5;
		
	#FROGGIT SPAWN COUNT
	var froggitCount : int = 0;
	if gm.roomCount >= 11:
		if gm.roomCount >= 35:
			froggitCount = 7;
		else:
			froggitCount = floor(gm.roomCount * 0.2) - 1;
	
	if gm.roomType == "enemy":
		await get_tree().create_timer(randf() * 0.5).timeout;
		print("-=-=- ENEMY COUNTS -=-=-")
		print("BAT: ", batCount);
		print("INV_MAN: ", invCount);
		print("FROGGIT: ", froggitCount);
		print("-=-=- ENEMY COUNTS -=-=-")
		for i : int in batCount:
			var bat : Node2D = batRess.instantiate();
			add_child(bat);
		for i : int in invCount:
			var inv : Node2D = invRess.instantiate();
			add_child(inv);
		for i : int in froggitCount:
			var froggit : Node2D = froggitRess.instantiate();
			add_child(froggit);
			
	if gm.roomType == "boss":
		var bossCount : int = 1 + (gm.roomCount / 40);
		if bossChance > 0.5 or true:
			for i : int in bossCount:
				var bat : Node2D = batRess.instantiate();
				bat.isBoss = true;
				add_child(bat);
		
	await get_tree().create_timer(3).timeout;
	gm.enemyCount -= 1;
	#$CollisionPolygon2D.disabled = false;
	
func _physics_process(_delta: float) -> void:
	if init:
		#NORMAL FIGHT ROOM
		if player.devCam:
			if selfType == "shop":
				$SHOP/mapPart.visible = true;
				$SHOP/mapPart.emitting = true;
			elif selfType == "gamble":
				$GAMBLE/mapPart.visible = true;
				$GAMBLE/mapPart.emitting = true;
		else:
			if selfType == "shop":
				$SHOP/mapPart.visible = false;
				$SHOP/mapPart.emitting = false;
			elif selfType == "gamble":
				$GAMBLE/mapPart.visible = false;
				$GAMBLE/mapPart.emitting = false;
				
		if !spawnedLoot and gm.enemyCount == 0 and gm.roomType == "enemy":
			if lootChance > 0.33:
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
			if lootChance > 0.5:
				spawnedLoot = true;
				var coin : Node2D = coinRess.instantiate();
				coin.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(coin);
				print("spawned coin! (loot)")
			elif lootChance > 0.25:
				spawnedLoot = true;
				var upgrade : Node2D = upgradeRess.instantiate();
				upgrade.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(upgrade);
				print("spawned upgrade! (loot)")
			else:
				spawnedLoot = true;
				var item : Node2D = itemRess.instantiate();
				item.position = gm.roomPos + Vector2(0, -32);
				$"..".add_child(item);
				print("spawned item! (loot)")
				
		#BOSS
		if !spawnedLoot and gm.roomType == "boss" and gm.enemyCount == 0:
			spawnedLoot = true;
			print("spawning boss loot");
			var item : Node2D = itemRess.instantiate();
			item.position = gm.roomPos;
			$"..".add_child(item);
			var coin1 : Node2D = coinRess.instantiate();
			coin1.position = gm.roomPos + Vector2(-64, 0);
			$"..".add_child(coin1);
			var coin2 : Node2D = coinRess.instantiate();
			coin2.position = gm.roomPos + Vector2(+64, 0);
			$"..".add_child(coin2);
	pass
