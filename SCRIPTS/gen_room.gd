extends Area2D

#@onready var static_body_2d: StaticBody2D = $"../StaticBody2D"
@onready var gm : Node2D= get_node("/root/game/gameManager");
@onready var player : Node2D = get_node("/root/game/player");

@onready var roomPos : Node2D = get_node("/root/game/roomContainer");
@onready var room : Resource = load("res://INST/room.tscn");
@onready var door : Resource = load("res://INST/wall.tscn")
@onready var raycast : RayCast2D = $raycast;
@onready var hasDoor : RayCast2D = $hasDoor;

var timer : float = 0.0
var x : int = 0;
var y : int = 0;
var used : bool= false;
@export var direction : String;

func doors() -> void:
	$newRoomIndicator.emitting = false;
	#await get_tree().create_timer(0.1).timeout;
	var _translation : Array = ["up", "right", "down", "left"];
	var doorInstance : Node = door.instantiate();
	get_parent().add_child(doorInstance);
	#print("n = ", gm.doorCounter, "; trans: ", translation[gm.doorCounter])
	if gm.doorCounter <= 2:
		gm.doorCounter+=1;
	else:
		gm.doorCounter = 0;
	pass

func _ready() -> void:
	call_deferred("doors");
	pass
		
func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= 5.0: 
		if !raycast.is_colliding() and !hasDoor.is_colliding():
			$newRoomIndicator.emitting = true;
		else:
			$newRoomIndicator.emitting = false;
		timer = 0.0 
		
	if (gm.roomCount + 1) % 10 == 0:
		$newRoomIndicator.modulate = Color(1, 0, 0);
	else:
		$newRoomIndicator.modulate = Color(1, 1, 1);
	
	if player.devCam:
		$"newRoomIndicator".visible = false;
		if !raycast.is_colliding() and !hasDoor.is_colliding():
			$"hasNewRoomIndicatorMap".emitting = true;
			$"hasNewRoomIndicatorMap".visible = true;
	else:
		$"newRoomIndicator".visible = true;
		$"hasNewRoomIndicatorMap".emitting = false;
		$"hasNewRoomIndicatorMap".visible = false;
	

func spawnRoom() -> void:
	gm.enemyCount += 1;
	gm.roomCount += 1;
	print("room count: ", gm.roomCount);
	#add_child(instance);
	print("Room Parent: ", get_parent().get_parent().name)
	var roomInstance : Node2D = room.instantiate();
	#roomInstance.global_position = gm.roomPos;
	roomPos.add_child(roomInstance);
	used = true;
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if raycast.is_colliding():
		print("raycast hit!");
		used = true;
	if (direction == "right" and gm.lastRoom == "left") or (direction == "left" and gm.lastRoom == "right") or (direction == "up" and gm.lastRoom == "down") or (direction == "down" and gm.lastRoom == "up"):
		used = true;
		pass;
	if body.name == "player":
		print("current Room: ", gm.roomPos);
		gm.nextRoom = direction;
		print("next room: ", gm.nextRoom);
		if !used:
			call_deferred("spawnRoom");
		if !used:
			body.canMove = false;
			await get_tree().create_timer(0.5).timeout;
			body.canMove = true;
